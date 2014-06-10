class ChangeScheduledTourDateTimeToDate < ActiveRecord::Migration
  def up
    remove_column :scheduled_tours, :datetime
    add_column :scheduled_tours, :date, :date
  end

  def down
    remove_column :scheduled_tours, :date
    add_column :scheduled_tours, :datetime, :datetime
  end
end
