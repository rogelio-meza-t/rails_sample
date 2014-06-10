class AddProductScheduleRefToScheduledTours < ActiveRecord::Migration
  
  def self.up
    change_table :scheduled_tours do |t|
      t.references :product_schedule
    end
  end

  def self.down
    remove_column :scheduled_tours, :product_schedule_id
  end
end
