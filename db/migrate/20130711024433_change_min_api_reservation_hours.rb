class ChangeMinApiReservationHours < ActiveRecord::Migration
  def change
    remove_column :products, :min_api_reservation_hours
    add_column :products, :min_api_reservation_hours, :integer, :default => 1
  end

end
