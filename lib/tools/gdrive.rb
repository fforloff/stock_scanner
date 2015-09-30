class Google_drive
  require 'google/api_client'
  require 'google/api_client/client_secrets'
  require 'google/api_client/auth/installed_app'
  require 'google/api_client/auth/storage'
  require 'google/api_client/auth/storages/file_store'
  require 'fileutils'

  APPLICATION_NAME = 'Stock Scanner'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               "stock-scanner.json")
  SCOPE = 'https://www.googleapis.com/auth/drive'

  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
    file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
    storage = Google::APIClient::Storage.new(file_store)
    auth = storage.authorize
    if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
      app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
      flow = Google::APIClient::InstalledAppFlow.new({
        :client_id => app_info.client_id,
        :client_secret => app_info.client_secret,
        :scope => SCOPE})
      auth = flow.authorize(storage)
      puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
    end
    auth
  end

  def initialize
    @client = Google::APIClient.new(:application_name => APPLICATION_NAME)
    @client.authorization = authorize
    @drive = @client.discovered_api('drive', 'v2')
  end

  def get_file_id(file_name, parent_id)
    file_id = nil
    results = @client.execute!(
      :api_method => @drive.files.list,
      :parameters => { :q => "title \= '#{file_name}' and trashed \= false and '#{parent_id}' in parents"})
    file_id = results.data.items.last.id unless results.data.items.empty?
  end

  def create_folder(folder_name, parent_folder_id)
    file = @drive.files.insert.request_schema.new({
      'title' => folder_name,
      'mimeType' => "application/vnd.google-apps.folder",
      'parents' => [{'id' => parent_folder_id}]
    })
    result = @client.execute(
      :api_method => @drive.files.insert,
      :body_object => file
      )
      if result.status == 200
        return result.data.id
      else
        return nil
      end
  end

  def get_or_create_parent_id(folders)
    parent_id = 'root'
    return parent_id if folders.length == 0
    folders = [folders] if folders.is_a?(String)
    folders.each do |folder|
      result = self.get_file_id(folder, parent_id)
      if result == nil
        parent_id = self.create_folder(folder, parent_id)
      else
        parent_id = result
      end
    end
    parent_id
  end

  def insert_file(local_file, file_mime_type, parent_id)
    file_name = File.basename local_file
    file = @drive.files.insert.request_schema.new({
      'title' => file_name,
      'mimeType' => file_mime_type
    })
    file.parents = [{'id' => parent_id}] unless parent_id.nil?
    media = Google::APIClient::UploadIO.new(local_file, file_mime_type, file_name)
    result = @client.execute(
      :api_method => @drive.files.insert,
      :body_object => file,
      :media => media,
      :parameters => {
        'uploadType' => 'multipart',
        'alt' => 'json'}
      )
      if result.status == 200
        return result.data.id
      else
        return nil
      end
  end

  def update_file(local_file, file_mime_type, file_id)
    file_name = File.basename local_file
    result = @client.execute(
      :api_method => @drive.files.get,
      :parameters => { 'fileId' => file_id })
    if result.status == 200
      file = result.data
      file.title = file_name
      file.mime_type = file_mime_type
      media = Google::APIClient::UploadIO.new(local_file, file_mime_type, file_name)
      result = @client.execute(
        :api_method => @drive.files.update,
        :body_object => file,
        :media => media,
        :parameters => {
          'fileId' => file_id,
          'newRevision?' => TRUE,
          'uploadType' => 'multipart',
          'alt' => 'json'}
        )
      if result.status == 200
        return result.data.id
      else
        return nil
      end
    end
  end

  def copy_to_gdrive(local_file, remote_path)
    # convert '/foo/bar' into ['foo','bar'] or '/' into []
    parent_folders = remote_path.gsub(/^\//, '').split('/')
    parent_id = get_or_create_parent_id(parent_folders)
    file_name = File.basename(local_file)
    file_mime_type = self.get_mime_type(local_file)
    file_id = get_file_id(file_name, parent_id)
    if file_id
      update_file(local_file, file_mime_type, file_id)
    else
      file_id = insert_file(local_file, file_mime_type, parent_id)
    end
    file_id
  end

  #         `cd /tmp; /usr/bin/pdf2ps #{list_name}.pdf; /usr/bin/ps2pdf #{list_name}.ps; /bin/rm #{list_name}.ps`
  def get_mime_type(file)
    ext_to_mime_type = {
      ".csv" =>"text/csv",

      ".doc" =>"application/msword",
      ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      ".htm" =>"text/html",
      ".html" =>"text/html",
      ".ods" =>"application/x-vnd.oasis.opendocument.spreadsheet",
      ".odt" =>"application/vnd.oasis.opendocument.text",
      ".pdf" =>"application/pdf",
      ".png" =>"image/png",
      ".ppt" =>"application/vnd.ms-powerpoint",
      ".pps" =>"application/vnd.ms-powerpoint",
      ".rtf" =>"application/rtf",
      ".swf" =>"application/x-shockwave-flash",
      ".sxw" =>"application/vnd.sun.xml.writer",
      ".txt" =>"text/plain",
      ".tsv" =>"text/tab-separated-values",
      ".tab" =>"text/tab-separated-values",
      ".xls" =>"application/vnd.ms-excel",
      ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      ".zip" =>"application/zip"
    }
    mime_type = ext_to_mime_type[File.extname(file)]
  end
end
