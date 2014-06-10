class AddSendDailyEmailToTourOperators < ActiveRecord::Migration
  def change
    add_column :tour_operators, :send_daily_email, :boolean, :default => false
  end
end
