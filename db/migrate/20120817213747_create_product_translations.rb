class CreateProductTranslations < ActiveRecord::Migration
  def self.up
    add_column :products, :internal_name, :string
    Product.update_all("internal_name = name")
    I18n.locale = :es
    Product.create_translation_table!({
      :name => :string,
      :description => :text,
      :difficulty => :string,
      :meeting_point => :string,
      :what_to_bring => :text,
      :whats_included => :text
    }, {
      :migrate_data => true,
      :remove_source_columns => true
    })
    
  end

  def self.down
    Product.drop_translation_table! :migrate_data => true
    remove_column :products, :internal_name
  end
end