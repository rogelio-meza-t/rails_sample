class AddStatusToProduct < ActiveRecord::Migration
  def up
    add_column :products, :status, :string, :default => "new"
    execute("UPDATE products SET status = 'active'")
  end
  
  def down
    remove_column :products, :status
  end
end
