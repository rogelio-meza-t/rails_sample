class AddOnTheFlyFlagToScheduledTours < ActiveRecord::Migration
  def change
    add_column :scheduled_tours, :on_the_fly, :boolean, default: false
  end
end
