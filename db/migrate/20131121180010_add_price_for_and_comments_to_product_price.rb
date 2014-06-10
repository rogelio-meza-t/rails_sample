class AddPriceForAndCommentsToProductPrice < ActiveRecord::Migration
  def change
  	add_column :product_prices, :price_for, :string
  	add_column :product_prices, :comments, :text
  end
end
