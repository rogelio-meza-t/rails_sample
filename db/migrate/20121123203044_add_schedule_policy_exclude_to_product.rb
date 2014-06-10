class AddSchedulePolicyExcludeToProduct < ActiveRecord::Migration
  def change
    add_column :products, :exempt_from_schedule_policy, :boolean, :default => false
  end
end
