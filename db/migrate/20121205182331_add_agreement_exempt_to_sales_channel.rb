class AddAgreementExemptToSalesChannel < ActiveRecord::Migration
  def change
    add_column :sales_channels, :agreement_exempt, :boolean, :default => false
  end
end
