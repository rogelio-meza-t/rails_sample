class AddCancelledBitToScheduledTour < ActiveRecord::Migration
  def change
    add_column :scheduled_tours, :cancelled, :boolean, :default => false
  end
end
