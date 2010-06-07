class Image < ActiveRecord::Base
  def self.save(upload)
        name =  "#{upload.original_filename}_#{DateTime.now}#{upload.original_filename.scan(/\.\w+$/)}"
        directory = "public/images/uploaded"
        #create the file path
        path = File.join(directory, name)
        # write the file
        File.open(path, "wb") { |f| f.write(upload.read) }
        return name
  end
end
