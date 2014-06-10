class AddPayPalEmailToTourOperator < ActiveRecord::Migration
  def change
    add_column :tour_operators, :paypal_email, :string
  end
end
