class RemoveTimezomeFromTourOperator < ActiveRecord::Migration
  def up
  	remove_column :tour_operators, :timezone
  end

  def down
  end
end
