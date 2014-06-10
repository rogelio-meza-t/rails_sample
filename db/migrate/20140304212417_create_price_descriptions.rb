class CreatePriceDescriptions < ActiveRecord::Migration
  def up
    create_table :price_descriptions do |t|
      t.integer :id
      t.integer :product_id
      t.timestamps
    end
    PriceDescription.create_translation_table! :description => :string
  end
  def down
    drop_table :price_descriptions
    PriceDescription.drop_translation_table!
  end
end