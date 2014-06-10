class CreateCategoriesRelationship < ActiveRecord::Migration
  def self.up
    create_table :product_categories do |t|
      t.string :name
      t.timestamps
    end
    create_table :product_categories_products, :id => false do |t|
      t.references :product, :product_category
    end
  end
  
  def self.down
    drop_table :product_categories
    drop_table :product_categories_products
  end
end
