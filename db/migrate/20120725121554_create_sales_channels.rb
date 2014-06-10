class CreateSalesChannels < ActiveRecord::Migration
  def change
    create_table :sales_channels do |t|
      t.string :name
      t.string :contact_name
      t.string :contact_email
      t.string :authentication_token

      t.timestamps
    end
  end
end
