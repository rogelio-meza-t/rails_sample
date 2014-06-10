class UseS3ForProductImages < ActiveRecord::Migration
  def up
    require "open-uri"
    ProductImage.all.each do |p|
      begin
        puts "uploading #{p.id} #{p.url}"
        if !p.url.blank? and !p.image.file?
          p.image = open(p.url)
          p.save
        end
      rescue Exception => e
        puts "Not able to upload #{p.id} #{p.url} #{e.message}"
      end
    end
  end
end
