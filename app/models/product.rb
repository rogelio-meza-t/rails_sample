class Product < ActiveRecord::Base

  after_update :update_api_availability_from_hours
  
  belongs_to :tour_operator
  has_many :product_images, :dependent => :destroy, :inverse_of => :product

  has_many :product_translations, :dependent => :destroy, :inverse_of => :product
  accepts_nested_attributes_for :product_translations, :reject_if => proc { 
    |attrs| attrs.reject{|k, v| (k == 'locale' && v != 'en') || v.blank? }.empty? 
  }

  has_many :scheduled_tours, :dependent => :destroy, :inverse_of => :product

  has_many :product_schedules, :dependent => :destroy, :inverse_of => :product

  has_many :price_descriptions, :dependent => :destroy, :inverse_of => :product
  
  has_and_belongs_to_many :product_categories
  attr_accessible :product_category_ids
  
  alias :images :product_images
  
  attr_accessible :name, :description, :difficulty, :duration, :languages,
                  :max_capacity, :meeting_point, :min_capacity,
                  :what_to_bring, :whats_included, :location,
                  :price_in_local_units, :tour_operator_id, :product_images_attributes,
                  :tour_operator, :product_schedules_attributes,
                  :translations_attributes, :min_api_reservation_hours,
                  :product_prices_attributes, :product_translations_attributes,
                  :status, :exempt_from_schedule_policy, :priority, :short_description, :price_descriptions_attributes
                  
  attr_accessible :product_image_ids, :images, :product_translation_ids
  
  accepts_nested_attributes_for :product_images, :allow_destroy => true
  accepts_nested_attributes_for :product_schedules, :allow_destroy => true
  #accepts_nested_attributes_for :product_prices, :allow_destroy => :true
  accepts_nested_attributes_for :price_descriptions, :allow_destroy => :true
  
  translates :description, :name, :difficulty, :meeting_point, 
             :what_to_bring, :whats_included, :short_description
   
  validates :max_capacity, :numericality => { :greater_than_or_equal_to => 1 }, :if => :active_or_capacity_and_timing?
  validates :min_capacity, :numericality => { :greater_than_or_equal_to => 1 }, :if => :active_or_capacity_and_timing?
  
  #validates :price_in_local_units, :numericality => { :greater_than_or_equal_to => 1 }, :if => :active_or_price?
  validate :min_less_than_max, :if => :active_or_capacity_and_timing?
  validates :location, :languages, :presence => true, :if => :active_or_basic?
  validates :short_description, length: {maximum: 140}, allow_blank: true
  validates :name, length: {maximum: 60}
  
  #before_validation :set_local_price_in_units, :if => :active_or_price?
  after_commit :delete_blank_translations
  
  # super big hack. Because of our odd usage of globalize3 gem we end up getting empty translations...
  def delete_blank_translations
    ProductTranslation.delete_all(["product_id = ? AND name is null AND description is null", self.id])
    self.reload      
  end
  
  def require_en_name
    en = product_translations.select { |p| p.locale.to_sym == :en }.first
    if en.nil? or en.name.blank?
      self.errors.add :name, I18n.t('errors.messages.blank')
    end
  end
  
  def require_en_description
    en = product_translations.select { |p| p.locale.to_sym == :en }.first
    if en.nil? or en.description.blank?
      self.errors.add :description, I18n.t('errors.messages.blank')
    end
  end
  
  def remove_blank_translations
    self.product_translations.delete_if{|x| x.locale.to_sym == :en and x.name.blank?}
    self.translations.delete_if{|x| x.locale.to_sym == :en and x.name.blank?}
  end
   
  def min_less_than_max
    if self.min_capacity && self.max_capacity && self.min_capacity > self.max_capacity
      self.errors.add :min_capacity, I18n.t('errors.messages.min_less_than_max') #' Min capacity must be greater than max capacity'
    end
  end
  
  def duration_time
    Time.new(2012, 01, 01, duration.to_i, (duration % duration.to_i) * 60) if duration?
  end
  
  def update_api_availability_from_hours
    if (self.min_api_reservation_hours_changed?)
      ScheduledTour.update_latest_api_reservation(self)
    end
  end
  
  def self.offered_by(tour_operator)
    Product.where('tour_operator_id' => tour_operator.id)
  end

  #def time_range
  #  start_time...(start_time+(1.hour*duration))
  #end
  
  # Checks if the price descriptions have a price in the given currency.
  # @param currency_code [String] the currency code
  # @return [Boolean] whether price descriptions have almost one price in the currency.
  #   Defaults true.
  def has_price_in_currency?(currency_code)
    currency_id = Currency.find_by_code(currency_code).id
    price_descriptions.each do |pd|
      if pd.product_prices.find_by_currency_id(currency_id).nil?
        return false
      end
    end
    true
  end
  
  #def price_in_currency(currency_code)
  #  hash = price_descriptions.first.product_prices.group_by{|p| p.currency_code}
  #  code = Money::Currency.new(currency_code).iso_code
  #  hash[code].first.monetized_price unless hash[code].nil?
  #end


  # Returns the lowest price in the given currency
  # @param  currency_code [String] the currency code
  # @return [Currency] the minimum price found
  def lowest_price(currency_code)
    currency_id = Currency.find_by_code(currency_code).id
    prices = []
    price_descriptions.each do |pd|
      pd.product_prices.each do |pp|
        prices << pp.monetized_price if pp.currency_id == currency_id
      end
    end    
    prices.min
  end
  
  def active?
    status == 'active'
  end
  
  def active_or_basic?
    status.include?('basic') || active?
  end
  
  def active_or_price?
    status.include?('price') || active?
  end
  
  def active_or_capacity_and_timing?
    status.include?('capacity_and_timing') || active?
  end
  
  # only used by sales embed iframe
  def self.in_date_range_with_categories_for(categories)
    joins(:product_categories).
    where(:product_categories => {:name => categories}).uniq
    #where('latest_api_reservation >= ?', DateTime.now.utc).uniq    
  end
  
  def self.owned_by_tour_operator(toguid)
    joins(:tour_operator).
    where(:tour_operators => {:guid => toguid}).uniq
  end
  
  # Check if in a Product is missing the USD price
  #   @see Product#has_price_in_currency?
  # @return [Boolean] whether USD price is missing
  def missing_usd_price?
    not has_price_in_currency?('USD')
  end
  
  # missing means it has neither a translation in the current locale nor an english translation
  def missing_translation?
    translation.new_record? && translation_for(:en).new_record?
  end
  
  def has_future_schedules?
    ps = product_schedules
      .select{|pss| pss.end_date > Date.today}
    ps.size != 0
  end


  # Find a price description
  # @param  id [Integer] The PriceDescription id
  # @return [PriceDescription] the price description found
  def price_description(id)
    price_descriptions.find_by_id(id)
  end

  # Returns the URL of featured image
  # @return [String] The image URL whether the product has almost one image, if not, returns a default image.
  def featured_image
    if images.size > 0
      images.first.image.url(:featured)
    else
      ActionController::Base.new.view_context.image_path('no-image-featured.jpg')
    end
  end


  # Returns a short_description of product. If short_description is not setted, it will return a truncated version of description
  # @return [String] Short product description
  def featured_description
    short_description.blank? ? description.truncate(140, separator: ".", omission: "...") : short_description
  end
end
