class CreateScheduledTours < ActiveRecord::Migration
  def change
    create_table :scheduled_tours do |t|
      t.datetime :datetime
      t.references :product

      t.timestamps
    end
    add_index :scheduled_tours, :product_id
  end
end
