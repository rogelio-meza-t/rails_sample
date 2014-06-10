class AddMinApiReservationHoursToProduct < ActiveRecord::Migration
  def change
    add_column :products, :min_api_reservation_hours, :integer, :default => 48
  end
end
