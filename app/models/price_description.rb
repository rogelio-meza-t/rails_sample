class PriceDescription < ActiveRecord::Base

  attr_accessible :id, :product_id, :minimum, :description, :name, :locale, :price_description_translations_attributes
  translates :description, :locale, :name, :fallbacks_for_empty_translations => true

  has_many :product_prices, :inverse_of => :price_description, :dependent => :destroy
  has_many :price_description_translations, :dependent => :destroy, :inverse_of => :price_description

  accepts_nested_attributes_for :price_description_translations

  belongs_to :product,  :inverse_of => :price_descriptions

  validates :description, length: {maximum: 20}
  validates :name, length: {maximum: 10}


  # Returns the product_price for the currency code in the actual price_description
  # @param currency_code [String] the currency code
  # @return [ProductPrice] the product_price object
  def get_price_by_currency(currency_code)
    currency_id = Currency.find_by_code(currency_code).id
    product_prices.find_by_currency_id(currency_id)
  end

  # Returns the monetized price for the given currency
  # @param  currency_code [String] the currency code
  # @return [Money] the monetized price
  def monetized_price_by_currency(currency_code)
    currency_id = Currency.find_by_code(currency_code).id
    product_prices.find_by_currency_id(currency_id).monetized_price
  end
 
  # Join in a string the name and the description if it exists
  # @return [String] name and description in the same string
  def price_name_and_description
    desc = ' ('+ description + ')' unless description.blank?
    "#{name}#{desc}"
  end
end