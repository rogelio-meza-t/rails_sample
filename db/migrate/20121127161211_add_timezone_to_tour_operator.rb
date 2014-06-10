class AddTimezoneToTourOperator < ActiveRecord::Migration
  def change
    add_column :tour_operators, :time_zone, :string, :limit => 255, :default => "UTC"
  end
end
