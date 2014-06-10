class AddAttachmentImageToProductImages < ActiveRecord::Migration
  def self.up
    change_table :product_images do |t|
      t.has_attached_file :image
    end
  end

  def self.down
    drop_attached_file :product_images, :image
  end
end
