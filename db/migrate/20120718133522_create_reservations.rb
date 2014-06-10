class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.references :product

      t.timestamps
    end
    add_index :reservations, :product_id
  end
end
