class ChangeLengthToFields < ActiveRecord::Migration
  def up
    change_column :product_translations, :name, :string, :limit => 60
    change_column :product_translations, :short_description, :string, :limit => 140
  end

  def down
  end
end
