class AddNameToPriceDescription < ActiveRecord::Migration
  def change
    add_column :price_description_translations, :name, :string
  end
end
