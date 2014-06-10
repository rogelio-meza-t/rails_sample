class ChangeCommentsToTextOnReservation < ActiveRecord::Migration
  def up
    change_column :reservations, :comments, :text
  end
  
  def down
    change_column :reservations, :comments, :string
  end
end
