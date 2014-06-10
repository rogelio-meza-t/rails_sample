class CurrencyPriceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value_before_monetized = record.send("#{attribute}_money_before_type_cast")
    record.original_value = value_before_monetized
    value = value_before_monetized.to_s.gsub(Money::Currency.new(record.currency_code).thousands_separator, '')
    value = value.to_s.gsub(Money::Currency.new(record.currency_code).decimal_mark, '.')
    # Extracted from activemodel's protected parse_raw_value_as_a_number
    parsed_value = case value
                   when /\A0[xX]/
                     nil
                   else
                     begin
                       Kernel.Float(value)
                     rescue ArgumentError, TypeError
                       nil
                     end
                   end
    unless parsed_value
      record.errors.add(attribute, :not_a_number)
    end
    record.errors.add(attribute, :greater_than, {:count => options[:greater_than]}) unless parsed_value > options[:greater_than]
  end
end