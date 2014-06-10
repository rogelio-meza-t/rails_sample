class AddCommentsToScheduledTour < ActiveRecord::Migration
  def change
    add_column :scheduled_tours, :comments, :text
  end
end
