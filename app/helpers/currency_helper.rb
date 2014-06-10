module CurrencyHelper
  include ActionView::Helpers::NumberHelper

  def display_in_local_currency(price_in_local_units)
    number_to_currency(price_in_local_units, unit: "CLP", precision: 0, delimiter: ".")
  end
end
