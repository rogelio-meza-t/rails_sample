class AddReservedCountToScheduledTour < ActiveRecord::Migration
  def up
  	add_column :scheduled_tours, :reserved_count, :integer
  end
  def down
  	remove_column :scheduled_tours, :reserved_count
  end
end
