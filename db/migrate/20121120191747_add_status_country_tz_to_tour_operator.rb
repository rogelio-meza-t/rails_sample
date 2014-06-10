class AddStatusCountryTzToTourOperator < ActiveRecord::Migration
  def up
    add_column :tour_operators, :status, :string, :default => "new"
    add_column :tour_operators, :country, :string
    add_column :tour_operators, :timezone, :string
    add_column :tour_operators, :preferred_language, :string
    execute("UPDATE tour_operators SET status = 'active'")
  end
  def down
    remove_column :tour_operators, :status
    remove_column :tour_operators, :country
    remove_column :tour_operators, :timezone
    remove_column :tour_operators, :preferred_language
  end
end
