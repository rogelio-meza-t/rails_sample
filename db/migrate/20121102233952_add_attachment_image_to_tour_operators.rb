class AddAttachmentImageToTourOperators < ActiveRecord::Migration
  def self.up
    change_table :tour_operators do |t|
      t.has_attached_file :image
    end
    require "open-uri"
    TourOperator.all.each do |to|
      begin
        puts "uploading #{to.id} #{to.logo}"
        if !to.logo.blank?
          to.image = open(to.logo)
          to.save
        end
      rescue Exception => e
        puts "Not able to upload #{to.id} #{to.logo} #{e.message}"
      end
    end
  end

  def self.down
    drop_attached_file :tour_operators, :image
  end
end
