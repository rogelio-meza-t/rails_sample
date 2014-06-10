class AddLocationToProducts < ActiveRecord::Migration
  def change
    add_column :products, :location, :string
  end
end
