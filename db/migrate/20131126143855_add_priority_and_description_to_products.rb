class AddPriorityAndDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :priority, :integer, default: 1
    add_column :products, :short_description, :string
  end
end
