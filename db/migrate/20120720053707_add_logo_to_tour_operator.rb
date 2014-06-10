class AddLogoToTourOperator < ActiveRecord::Migration
  def change
    add_column :tour_operators, :logo, :string
  end
end
