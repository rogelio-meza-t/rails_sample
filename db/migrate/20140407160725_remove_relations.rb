class RemoveRelations < ActiveRecord::Migration
  def up
  	#remove relations and attributes from products table
  	remove_column :products, :internal_name
  	remove_column :products, :start_time
  	remove_column :products, :price_in_local_units

  	remove_column :product_prices, :price_for
  	remove_column :product_prices, :comments
  	remove_column :product_prices, :currency_code
  end

  def down
  	#add_column :products, :internal_name
  	#add_column :products, :start_time
  	#add_column :products, :price_in_local_units

  	#add_column :product_prices, :price_for
  	#add_column :product_prices, :comments
  	#add_column :product_prices, :currency_code
  end
end
