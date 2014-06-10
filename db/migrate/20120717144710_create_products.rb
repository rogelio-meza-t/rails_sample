class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string     :name
      t.text       :description
      t.string     :difficulty
      t.integer    :min_capacity
      t.integer    :max_capacity
      t.string     :duration
      t.datetime   :start_time
      t.text       :whats_included
      t.text       :what_to_bring
      t.string     :meeting_point
      t.string     :languages
      t.references :tour_operator

      t.timestamps
    end
    add_index :products, :tour_operator_id
  end
end
