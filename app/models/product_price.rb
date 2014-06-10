class ProductPrice < ActiveRecord::Base

  ValidCurrencies    = Currency.all.map &:code
  AvailableCurrencies = Currency.all
  
  RequiredCurrencies = ['USD']

  belongs_to :price_description, :inverse_of => :product_prices
  has_one :currency
  
  attr_accessor :original_value
  
  attr_accessible :product, :product_id, :price, :monetized_price, :original_value, :currency_id, :comments, :price_description_id, :currency_code
  
  monetize :price, :as => "monetized_price", :with_model_currency => :currency_code
  
  validates :monetized_price, :numericality => {:greater_than => 0}
  
  before_validation do
    self.original_value = self.original_value || monetized_price_money_before_type_cast
    instance_variable_set "@monetized_price_money_before_type_cast", self.original_value
  end

  #before_save do
  #  c = Currency.find_by_code self.currency_code
  #  self.currency_id = c.id
  #end

  #se ocupará en las vistas, revisarlas luego de la subida de versión
  def delocalize_price
    self.price_local = price_local.to_s.gsub(Money::Currency.new(currency_code).decimal_mark, ".")
  end
  
  def currency_code_enum
    ValidCurrencies
  end

  def currency
    if currency_id != nil
      Currency.find currency_id
    end
  end

  #def get_currency_code
  #  Currency.find(currency_id).code
  #end

  def self.default_currencies
    a = []
    a << {:code => 'USD', :order => '0'}
    a << {:code => 'EUR', :order => '1'}
    a << {:code => 'CLP', :order => '2'}
    a << {:code => 'MXN', :order => '3'}

    b = Currency.all.map{|c| {:code => c.code, :id => c.id}}

    ab = a+b
    ab.group_by{|x| x[:code]}.map{|k,v| v.inject(:merge)}.sort_by{|c| c[:order]}
  end
  
  def self.valid_paypal_currency?(curr)
    # https://www.x.com/developers/paypal/documentation-tools/api/Pay-api-operation
    ['USD', 'EUR', 'MXN'].include? curr
  end
  
end
