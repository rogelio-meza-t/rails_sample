class ChangeProductStartTimeToTime < ActiveRecord::Migration
  def up
    change_column :products, :start_time, :time
  end

  def down
    change_column :products, :start_time, :datetime
  end
end
