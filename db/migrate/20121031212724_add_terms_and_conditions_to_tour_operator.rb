class AddTermsAndConditionsToTourOperator < ActiveRecord::Migration
  def self.up
    I18n.locale = :es
    add_column :tour_operators, :terms_and_conditions, :text
    TourOperator.create_translation_table!({
      :description => :text,
      :terms_and_conditions => :text
    }, {
      :migrate_data => true,
      :remove_source_columns => true
    })
    
  end

  def self.down
    TourOperator.drop_translation_table! :migrate_data => true
  end
end
