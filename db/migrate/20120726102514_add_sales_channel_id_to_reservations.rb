class AddSalesChannelIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :sales_channel_id, :integer
  end
end
