class AddCurrencyIdToProductPrice < ActiveRecord::Migration
  def change
    add_column :product_prices, :currency_id, :integer
  end
end
