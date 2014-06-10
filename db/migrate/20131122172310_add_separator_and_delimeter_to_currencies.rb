class AddSeparatorAndDelimeterToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :separator, :string
    add_column :currencies, :delimeter, :string
  end
end
