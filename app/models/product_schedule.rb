#encoding: utf-8

class ProductSchedule < ActiveRecord::Base
  attr_accessible :days, :end_date, :start_date, :product, :product_id, :active, :start_time
  belongs_to :product
  has_many :scheduled_tours, :dependent => :destroy, :inverse_of => :product_schedule

  before_validation :normalize_days
  before_validation :assign_start_time
  after_create :schedule_tours
  after_update :reschedule_tours
  
  validates :start_time, presence: true
  validate :days_selected
  validate :start_before_end_date
  
  scope :active, where(active: true)

  #revisar la lógica para implementarla en otro lado
  def no_overlaps
    unless errors.any?
      number_set = ScheduledTour.translate_days_to_number_set(days_as_array)
      will_be_scheduled = (start_date..end_date).select{|d| number_set.include?(d.wday)}
      overlaps = ScheduledTour.joins(:product_schedule)
        .where('product_schedules.active' => true)
        .where(:date => will_be_scheduled, :product_id => product.id, :cancelled => false)
      errors.add(:overlaps, I18n.t('errors.messages.overlaps')) unless overlaps.empty?
    end
  end
  
  def days_selected
    if !days.is_a?(String) && (days.nil? || days.reject(&:empty?).size == 0)
      self.errors.add :days, I18n.t('errors.messages.atleast_one_day') #' You must select at least one day to schedule this product'
    end
  end
  
  def start_before_end_date
    if self.start_date && self.end_date && self.start_date > self.end_date
      self.errors.add :start_date, I18n.t('errors.messages.start_before_end') #' Start date must be before end date'
    end
  end
  #validates_date :start_date, :allow_blank => true
  #validates_date :end_date, :allow_blank => true
  
  def normalize_days
    self.days = days.reject(&:empty?).join(",") unless days.is_a?(String)
  end

  def assign_start_time
    self.start_time = start_time
  end
  
  def schedule_tours
    self.reload
    ScheduledTour.populate(product, start_date..end_date, days_as_array, self)
  end
  
  def reschedule_tours
    self.reload
    if active
      # interestingly delete_all here actually deletes each one individually
      self.scheduled_tours.delete_all
      ScheduledTour.populate(product, start_date..end_date, days_as_array, self)
    end
  end
  
  def days_as_array
    days.split(/,|\s/).reject(&:empty?).map(&:downcase).
      map { |day| translate(day) || day }.
      map(&:to_sym)
  end

  def deactivate
    if active
      toggle!(:active)
    end
  end
  
  private

  def translate(day_name)
    SPANISH_DAY_NAMES[day_name]
  end

  SPANISH_DAY_NAMES = {
    'lunes'     => 'monday',
    'martes'    => 'tuesday',
    'miercoles' => 'wednesday',
    'miércoles' => 'wednesday',
    'jueves'    => 'thursday',
    'viernes'   => 'friday',
    'sabado'    => 'saturday',
    'sábado'    => 'saturday',
    'domingo'   => 'sunday'
  }
end
