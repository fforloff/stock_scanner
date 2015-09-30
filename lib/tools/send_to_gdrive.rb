def send_to_gdrive(site_url,tpm_dir,remote_dir)
	require 'gdrive'
	require 'open-uri'
	gd = Google_drive.new
	List.each do |list|
		local_file = "#{tpm_dir}/#{list.name}.pdf"
		pdf_url = "#{site_url}/lists/#{list.name}.pdf"
	  open(local_file,'wb') do |file|
	  	file << open(pdf_url).read
	  end
#        `cd /tmp; /usr/bin/pdf2ps #{list_name}.pdf; /usr/bin/ps2pdf #{list_name}.ps; /bin/rm #{list_name}.ps`
		gd.copy_to_gdrive(local_file, remote_dir)
	end
end
