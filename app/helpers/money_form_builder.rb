class MoneyFormBuilder < ActionView::Helpers::FormBuilder
  
  def money_field(method, options = {})
    value = @object.send(method)
    formatted_value = @object.monetized_price_money_before_type_cast || @object.original_value || value.to_s
    text_field method, options.merge(:value => (formatted_value))
  end
  
  def globalize_fields_for(locale, *args, &proc)
    raise ArgumentError, "Missing block" unless block_given?
    @index = @index ? @index + 1 : 1
    object_name = "#{@object_name}[#{@object_name}_translations_attributes][#{@index}]"
    #object = @object.translations.find_by_locale locale.to_s
    # TODO
    object = @object.send("#{@object_name}_translations").detect{|t| t.locale == locale.to_s}
    
    @template.concat @template.hidden_field_tag("#{object_name}[id]", object ? object.id : "")
    @template.concat @template.hidden_field_tag("#{object_name}[locale]", locale)
    if @template.respond_to? :simple_fields_for
      @template.simple_fields_for(object_name, object, *args, &proc)
    else
      @template.fields_for(object_name, object, *args, &proc)
    end
  end
end