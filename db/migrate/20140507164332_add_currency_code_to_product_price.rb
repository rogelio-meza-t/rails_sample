class AddCurrencyCodeToProductPrice < ActiveRecord::Migration
  def up
  	add_column :product_prices, :currency_code, :string, :length => 4
  end
  def down
  	remove_column :product_prices, :currency_code
  end
end
