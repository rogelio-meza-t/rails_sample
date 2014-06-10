class PriceInLocalCurrency < ActiveRecord::Migration
  def change
    add_column :products, :price_in_local_units, :integer
    remove_column :products, :price_in_cents
  end
end
