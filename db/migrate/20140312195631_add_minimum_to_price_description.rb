class AddMinimumToPriceDescription < ActiveRecord::Migration
  def up
    add_column :price_descriptions, :minimum, :integer
  end
  def down
    remove_column :price_descriptions, :minimum
  end
end
