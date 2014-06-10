class AddPlaceOfStayToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :place_of_stay, :string
  end
end
