class CreateRequestLogs < ActiveRecord::Migration
  def change
    create_table :request_logs do |t|
      t.string :url
      t.string :key
      t.string :value
      t.references :sales_channel

      t.timestamps
    end
  end
end
