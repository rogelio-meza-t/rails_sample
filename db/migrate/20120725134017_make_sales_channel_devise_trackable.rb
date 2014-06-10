class MakeSalesChannelDeviseTrackable < ActiveRecord::Migration
  def change
    add_column :sales_channels, :sign_in_count, :integer, :default => 0
    add_column :sales_channels, :current_sign_in_at, :datetime
    add_column :sales_channels, :last_sign_in_at,    :datetime
    add_column :sales_channels, :current_sign_in_ip, :string
    add_column :sales_channels, :last_sign_in_ip,    :string
  end
end
