class RenameDelimiterToDelimiter < ActiveRecord::Migration
  def change
  	rename_column :currencies, :delimeter, :delimiter
  end
end
