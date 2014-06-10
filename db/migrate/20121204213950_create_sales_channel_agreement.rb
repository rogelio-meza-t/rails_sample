class CreateSalesChannelAgreement < ActiveRecord::Migration
  def change
    create_table :sales_channel_agreements do |t|
      t.references :sales_channel
      t.string :text
      t.integer :commission_percent

      t.timestamps
    end
    add_index :sales_channel_agreements, :sales_channel_id
  end
end
