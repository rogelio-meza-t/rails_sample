class CurrencySafeNumericalityValidator < ActiveModel::Validations::NumericalityValidator
  def validate_each(record, attribute, value)
    value_before_monetized = record.send("#{attribute}_money_before_type_cast")
    #record.original_value = value_before_monetized
    currency = record.send("currency_for_#{attribute}")
    decimal_pieces = value_before_monetized.split(currency.decimal_mark)
    if decimal_pieces.length > 2
      record.errors.add(attribute, I18n.t('errors.messages.invalid_currency', { :thousands => currency.thousands_separator, :decimal => currency.decimal_mark }))
    end
    pieces = decimal_pieces[0].split(currency.thousands_separator)
    if pieces.length > 1
      record.errors.add(attribute, I18n.t('errors.messages.invalid_currency', { :thousands => currency.thousands_separator, :decimal => currency.decimal_mark })) unless pieces[0].length <= 3
      (1..pieces.length-1).each do |index|
        record.errors.add(attribute, I18n.t('errors.messages.invalid_currency', { :thousands => currency.thousands_separator, :decimal => currency.decimal_mark })) unless pieces[index].length == 3
      end
    end
    
    value = value_before_monetized.to_s.gsub(currency.thousands_separator, '')
    value = value.to_s.gsub(currency.decimal_mark, '.')
    
    super(record, attribute, value)
  end
end