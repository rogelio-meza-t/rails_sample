class CreateTourOperators < ActiveRecord::Migration
  def change
    create_table :tour_operators do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.string :contact_person
      t.text   :description

      t.timestamps
    end
  end
end
