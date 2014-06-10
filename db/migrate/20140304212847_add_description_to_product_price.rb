class AddDescriptionToProductPrice < ActiveRecord::Migration
  def change
    add_column :product_prices, :price_description_id, :integer
  end
end