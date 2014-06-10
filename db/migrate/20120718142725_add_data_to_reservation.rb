class AddDataToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :contact_name, :string
    add_column :reservations, :email, :string
    add_column :reservations, :phone, :string
    add_column :reservations, :number_of_people, :integer
  end
end
