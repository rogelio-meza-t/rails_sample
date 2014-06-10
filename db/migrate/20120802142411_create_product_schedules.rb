class CreateProductSchedules < ActiveRecord::Migration
  def change
    create_table :product_schedules do |t|
      t.date      :start_date
      t.date      :end_date
      t.string    :days
      t.references :product

      t.timestamps
    end
  end
end
