require 'spec_helper'
require 'support/reservations'

describe Reservation do

  let(:reservation) { FactoryGirl.create :reservation }

  it 'can be saved' do
    reservation = Reservation.new(
      contact_name: "Fred",
      email: 'fred@gmail.com',
      number_of_people: 4,
      phone: '09 4444 555',
      comments: 'Something else',
      scheduled_tour_id: 1)
    reservation.save!
    fetched_reservation = Reservation.find_by_contact_name("Fred")
    fetched_reservation.id.should be >= 0
  end

  context 'knows the reserved dates of a tour operator within a date range' do
    let(:tour_operator) { FactoryGirl.create :tour_operator }
    it 'dates in the same year' do
      date1 = reserve(tour_operator, Date.new(2012, 7, 10))
      date2 = reserve(tour_operator, Date.new(2012, 8, 1))
      out_of_range = reserve(tour_operator, Date.new(2012, 9, 23))
      cancelled = reserve(tour_operator, Date.new(2012, 7, 23))
      cancelled.cancel && cancelled.save!

      date_range = Date.new(2012,7)...Date.new(2012,9)
      Reservation.for(tour_operator, date_range).should include(date1, date2)
      Reservation.for(tour_operator, date_range).should_not include(out_of_range, cancelled)
    end

    it 'dates in different years' do
      date1 = reserve(tour_operator, Date.new(2012, 12, 20))
      date2 = reserve(tour_operator, Date.new(2013, 1, 2))
      out_of_range = reserve(tour_operator, Date.new(2013, 2, 1))

      date_range = Date.new(2012,12)...Date.new(2013,2)
      Reservation.for(tour_operator, date_range).should include(date1, date2)
      Reservation.for(tour_operator, date_range).should_not include(out_of_range)
    end
  end

  context "cancelling a reservation" do
    it "marks the object" do
      reservation.cancelled.should == false
      reservation.cancel
      reservation.cancelled.should == true
    end

    it 'persists the change' do
      reservation.cancel
      round_tripped = Reservation.find(reservation.id)
      round_tripped.cancelled.should == true
    end
  end

  it 'has a reference number' do
    expected_reference = reservation.id + Reservation::STARTING_RESERVATION_QUANTITY
    reservation.reference.should eq expected_reference
  end
end
