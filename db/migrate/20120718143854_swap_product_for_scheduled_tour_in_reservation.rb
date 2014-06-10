class SwapProductForScheduledTourInReservation < ActiveRecord::Migration
  def up
    add_column :reservations, :scheduled_tour_id, :integer
    remove_column :reservations, :product_id
  end

  def down
    add_column :reservations, :product_id, :integer
    remove_column :reservations, :scheduled_tour_id
  end
end
