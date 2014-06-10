class AddScheduledTourPolicyToOperator < ActiveRecord::Migration
  def change
    add_column :tour_operators, :scheduled_tour_availability_policy, :string
    add_column :tour_operators, :scheduled_tour_availability_policy_parameters, :string
  end
end
