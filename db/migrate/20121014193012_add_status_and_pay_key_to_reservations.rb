class AddStatusAndPayKeyToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :paykey, :string
    add_column :reservations, :paid, :boolean, :default => true
  end
end
