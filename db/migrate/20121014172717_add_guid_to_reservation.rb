class AddGuidToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :guid, :string, :limit => 40
  end
end
