class ChangeDurationToDecimal < ActiveRecord::Migration
  def up
    change_column :products, :duration, :decimal, precision: 3, scale: 1
  end

  def down
    change_column :products, :duration, :integer
  end
end
