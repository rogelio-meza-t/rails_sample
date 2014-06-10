class Reservation < ActiveRecord::Base
  
  STARTING_RESERVATION_QUANTITY = 2000
  belongs_to :scheduled_tour
  belongs_to :sales_channel

  attr_accessible :contact_name, :email, :number_of_people, :phone, :comments,
                  :scheduled_tour_id, :sales_channel, :sales_channel_id, :scheduled_tour,
                  :place_of_stay, :guid, :paykey, :paid, :terms_and_conditions
  
  validates :contact_name, :email, :presence => true
  validates :number_of_people, :presence => true, :numericality => { :only_integer => true }
  validates :terms_and_conditions, :acceptance => true
  validates_format_of :email, :with => /@/
  

  after_update :update_reserved_count


  def self.for(tour_operator, date_range)
    Reservation.joins(:scheduled_tour => [ :product => :tour_operator]).
      where('tour_operators.id' => tour_operator.id).
      where('scheduled_tours.date' => date_range)
  end

  def cancel
    self.cancelled = true
    self.save!
  end
  
  def uncancel
    self.cancelled = false
    self.save!
  end
  
  def unpaid
    !self.paid
  end

  def reference
    self.id.to_i + STARTING_RESERVATION_QUANTITY
  end
  
  def self.delete_unpaid_reservations
    Reservation.delete_all('created_at < ? AND paid = false', DateTime.now - 2.days)
  end

  # Calculates the total price for purchased tickets
  # @param  tickets [Array<Array<String, String>>] An array containing information about purchased tickets.
  #   Array<PriceDescription.id, quantity>
  # @param curency [String] currency code
  # @return [Money] total price of purchase
  def total_price(tickets, currency)
    total = Money.new(0, currency)
    product = scheduled_tour.product
    tickets.each do |t|
      price_description_id, quantity = t[0].to_i, t[1].to_i

      if quantity != 0
        price_description = product.price_description(price_description_id)
        price = price_description.monetized_price_by_currency(currency)

        partial = price * quantity
        total = total + partial
      end
    end
    total
  end

  # Creates an array of hashes with information about purchased tickets
  # @param tickets [Array<Array<String, String>>] an array containing price id and quantity
  # @param currency [String] the currency code
  # @return [Array<Hash>] purchase information for views
  def purchased_tickets(tickets, currency)
    ticket_info = []
    product = scheduled_tour.product
    tickets.each do |t|
      price_description_id, quantity = t[0].to_i, t[1].to_i

      if quantity != 0
        price_description = product.price_description(price_description_id)

        ticket_info << {
          :quantity_and_name => "#{quantity} x #{price_description.name}",
        }
      end
    end
  end
  
  def update_reserved_count
    if (cancelled_changed? or paid_changed?)
      st = scheduled_tour
      if (cancelled == true)
        people = st.reserved_count - number_of_people
      else
        people = st.reserved_count + number_of_people
      end
      st.update_attributes({:reserved_count => people})
    end
  end
end
