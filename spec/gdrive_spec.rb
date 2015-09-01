require_relative '../lib/tools/gdrive'
require 'pp'

describe Google_drive do 
	before do
		@gd = Google_drive.new
	end

	# it "get_file_id should return an id for an existing file" do
	# 	file_id = @gd.get_file_id('Position sizing.xls', '0B1sRwjmMgNEVYWJvMnd0QjI5U00')
	# 	pp file_id
	# 	expect(file_id).not_to eq(nil)
	# end

	# it "get_parent_id should return an id for an existing folder" do
	# 	expect(@gd.get_parent_id('Shares trading')).to eq("0B1sRwjmMgNEVYWJvMnd0QjI5U00")
	# end

	# it "should return an id for an existing folder" do
	# 	expect(@gd.get_parent_id(['Shares trading','Scanner Reports'])).not_to eq(nil)
	# end

	# it "should return nil for a non-existing folder" do
	# 	expect(@gd.get_parent_id(['Shares bla'])).to eq(nil)
	# end

	# it "get_or_create_parent_id should return root if no folder are given" do
	# 	expect(@gd.get_or_create_parent_id([''])).to eq('root')
	# end
	
	# it "get_or_create_parent_id should non-nil when creating folder" do
	#  	folder_id = @gd.get_or_create_parent_id(['3test3','bla folder'])
	#  	expect(folder_id).not_to eq(nil)
	#  	pp folder_id 
	# end
	#  it "insert file should return non-nil when uploading a new file" do
	# 	file_id = @gd.insert_file('/tmp/testtest.pdf','application/pdf', ['3test3','bla folder','ggg'])
	#  	expect(file_id).not_to eq(nil)
	#  	pp file_id 
	# end	
	# it "update file should return non-nil when updating an existing file" do
	# 	file_id = @gd.update_file('/tmp/testtest.pdf','application/pdf',"0B1sRwjmMgNEVZk9EMmtVX3hOdGM")
	#   	expect(file_id).to eq("0B1sRwjmMgNEVZk9EMmtVX3hOdGM")
	#   	pp file_id
	# end
	it "copy_to_grive should return a non-nil file_id" do
		file_id = @gd.copy_to_gdrive('/tmp/testtest.pdf', '/3test3/bla folder/ggg', 'application/pdf')
		expect(file_id).not_to eq(nil)
		pp file_id
	end
end
