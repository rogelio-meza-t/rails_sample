class AddGuidToTourOperatorsAndSalesChannels < ActiveRecord::Migration
  def up
    require 'uuidtools'
    
    add_column :tour_operators, :guid, :string, :limit => 40
    TourOperator.all.each do |to|
      to.guid = UUIDTools::UUID.timestamp_create().to_s
      puts "updating #{to.id} - #{to.guid}"
      to.save!
    end
    
    add_column :sales_channels, :guid, :string, :limit => 40
    SalesChannel.all.each do |st|
      st.guid = UUIDTools::UUID.timestamp_create().to_s
      st.save
    end
  end
  
  def down
    remove_column :tour_operators, :guid
    remove_column :sales_channels, :guid
  end
end
