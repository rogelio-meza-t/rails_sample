class AddActiveFlagToProductSchedule < ActiveRecord::Migration
  def change
    add_column :product_schedules, :active, :boolean, :default => true
  end
end
