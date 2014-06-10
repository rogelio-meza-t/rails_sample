class AddDefaultValuesToProduct < ActiveRecord::Migration
  def up
    change_column :products, :min_capacity, :integer, default: 0
    change_column :products, :max_capacity, :integer, default: 0
    remove_column :products, :duration
    add_column    :products, :duration, :integer, default: 0
  end

  def down
    change_column :products, :min_capacity, :integer, default: nil
    change_column :products, :max_capacity, :integer, default: nil
    remove_column :products, :duration
    add_column    :products, :duration, :string
  end
end
