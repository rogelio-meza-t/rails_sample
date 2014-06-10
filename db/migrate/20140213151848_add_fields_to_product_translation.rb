class AddFieldsToProductTranslation < ActiveRecord::Migration
  def up
    I18n.locale = :es
    Product.add_translation_fields!({
      :short_description => :string
    }, {
      :migrate_data => true,
      :remove_source_columns => true
    })
  end
  def down
    
  end
end
