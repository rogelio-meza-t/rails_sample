class CreateProductPrices < ActiveRecord::Migration
  def up
    create_table :product_prices do |t|
      t.references :product
      t.string :currency_code, :limit => 8
      t.integer :price
      t.timestamps
    end
    add_index :product_prices, :product_id
    puts "Adding index"
    Product.all.each do |p|
      puts "#{p.name} #{p.price_in_local_units}"
      p.product_prices.build({:currency_code => "CLP", :price => p.price_in_local_units})
      p.save!
      puts p.product_prices.size
    end
  end

  def down
    drop_table :product_prices
  end
end
