require 'spec_helper'
require 'support/schedule_tours'

describe ScheduledTour do
  let(:product)        { FactoryGirl.create :product }
  let(:tour_operator) { FactoryGirl.create(:tour_operator) }

  let(:empty_scheduled_tour) { FactoryGirl.create :scheduled_tour, product: product }

  let(:tour_with_reservation) {
    tour = FactoryGirl.create :scheduled_tour, product: product
    tour.reservations << reservation_attached_to_tour
    tour
  }
  let(:reservation_attached_to_tour)  do
    FactoryGirl.create(:reservation, contact_name: "name",
                                     email: "email",
                                     phone: "phone")
  end

  it 'returns even tours that have been cancelled' do
    tour_with_reservation.reservations.count.should == 1
    tour_with_reservation.reservations[0].cancel
    tour_with_reservation.reservations.count.should == 1
  end

  it 'knows the upcoming scheduled tours of a tour operator' do
    future, past = Date.tomorrow+3, Date.yesterday-3
    scheduled1 = schedule(:rafting_morning, tour_operator, future)
    scheduled2 = schedule(:rafting_afternoon, tour_operator, future)
    scheduled3 = schedule(:hiking, tour_operator, future)
    past       = schedule(:hiking, tour_operator, past)
    cancelled  = schedule(:hiking, tour_operator, future)
    cancelled.cancel

    ScheduledTour.upcoming_of(tour_operator).
      should include(scheduled1, scheduled2, scheduled3)
    ScheduledTour.upcoming_of(tour_operator).should_not include(past, cancelled)
  end

  it 'knows the upcoming scheduled tours of a tour operator on a date' do
    date = 1.month.from_now
    scheduled1 = schedule(:rafting_morning, tour_operator, date)
    scheduled2 = schedule(:rafting_afternoon, tour_operator, date)
    scheduled3 = schedule(:hiking, tour_operator, 32.days.from_now)

    ScheduledTour.on_date_of(date, tour_operator).should include(scheduled1, scheduled2)
    ScheduledTour.on_date_of(date, tour_operator).should_not include(scheduled3)
  end

  it 'knows the family of tours from same operator on same date (including self)' do
    today = schedule(:rafting_morning, tour_operator, Date.today)
    also_today = schedule(:rafting_afternoon, tour_operator, Date.today)
    not_today = schedule(:hiking, tour_operator, 32.days.from_now)

    today.date_family.to_set.should == [today, also_today].to_set
  end

  it 'can return the contact information for all reservations' do
    tour_with_reservation.contact_information.should == [{
      contact_name: reservation_attached_to_tour.contact_name,
      email: reservation_attached_to_tour.email,
      phone: reservation_attached_to_tour.phone
    }]
  end

  context "cancelling a tour" do
    it 'cancels it and its reservations' do
      tour_with_reservation.cancelled.should == false
      reservation_attached_to_tour.cancelled.should == false

      tour_with_reservation.cancel

      tour_with_reservation.cancelled.should == true
      reservation_attached_to_tour.cancelled.should == true
    end

    it 'does not change the reservation count, just the state of the reservation' do
      tour_with_reservation.reservations.count.should == 1
      tour_with_reservation.cancel
      tour_with_reservation.reservations.count.should == 1
    end

    it "persists the changes" do
      tour_with_reservation.cancel

      round_tripped = ScheduledTour.find(tour_with_reservation.id)
      round_tripped.cancelled.should == true
      round_tripped.reservations.first.cancelled.should == true
    end
  end

  it "knows if it has any reservations at all" do
    empty_scheduled_tour.should_not have_reservations
    tour_with_reservation.should have_reservations
  end

  it "knows if it is full" do
    product.max_capacity = 5
    empty_scheduled_tour.should_not be_full

    reservation_attached_to_tour.number_of_people = 4
    tour_with_reservation.should_not be_full

    reservation_attached_to_tour.number_of_people = 5
    tour_with_reservation.should be_full
  end

  context 'knows if it has spots for a given number of people' do
    it 'without previous reservations' do
      product.max_capacity = 4
      empty_scheduled_tour.should have_room_for(4)
      empty_scheduled_tour.must_have_room_for(4).should be_success

      empty_scheduled_tour.should_not have_room_for(5)
      empty_scheduled_tour.must_have_room_for(5).should be_failure

      empty_scheduled_tour.room_available.should == 4
    end

    it 'with previous reservations' do
      product.max_capacity = 5
      reservation_attached_to_tour.number_of_people = 3
      tour_with_reservation.should have_room_for(2)
      tour_with_reservation.must_have_room_for(2).should be_success

      tour_with_reservation.should_not have_room_for(3)
      tour_with_reservation.must_have_room_for(3).should be_failure

      tour_with_reservation.room_available.should == 2
    end

    it 'with cancelled previous reservations' do
      product.max_capacity = 5
      reservation_attached_to_tour.number_of_people = 3
      reservation_attached_to_tour.cancel

      tour_with_reservation.should have_room_for(5)
      tour_with_reservation.must_have_room_for(5).should be_success

      tour_with_reservation.should_not have_room_for(6)
      tour_with_reservation.must_have_room_for(6).should be_failure

      tour_with_reservation.room_available.should == 5
    end

    it 'and can say how much room is available' do
      product.max_capacity = 4
      failure = empty_scheduled_tour.must_have_room_for(5)
      failure.fetch[:room_available].should == 4
    end

  end

  it "accepts a zero-day date range" do
    date = Date.new(2012, 3, 5)

    # Narrowest sensible range
    tour = FactoryGirl.create(:scheduled_hiking, date: date)
    ScheduledTour.in_date_range(date..date).should == [tour]

    # Ridiculous range
    ScheduledTour.in_date_range(date..(date-1)).should == []
    ScheduledTour.in_date_range(date...date-1).should == []
    ScheduledTour.in_date_range(date...date-100).should == []
  end


  it "knows how to find not on the fly tours matching a date range" do
    before = FactoryGirl.create(:scheduled_hiking,
                                date: Date.new(2012, 3, 5))
    first = FactoryGirl.create(:scheduled_hiking,
                               date: Date.new(2012, 3, 6))
    last = FactoryGirl.create(:scheduled_hiking,
                              date: Date.new(2012, 3, 7))
    after = FactoryGirl.create(:scheduled_hiking,
                               date: Date.new(2012, 3, 8))
    actual = ScheduledTour.in_date_range(Date.new(2012, 3, 6)..Date.new(2012, 3, 7))
    Set.new(actual).should == Set.new([first, last])
  end

  it 'knows if the tour is an on the fly tour or not' do
    tour = FactoryGirl.create(:scheduled_hiking)
    tour.should_not be_on_the_fly
    tour.update_attribute(:on_the_fly, true)
    tour.should be_on_the_fly
  end

  context "it can create an entire range of instances" do
    first_date = Date.new(2012, 8, 1)
    final_date = Date.new(2012, 8, 10)
    range = first_date..final_date

    it "by passing in a date range and the desired days of the week" do
      ScheduledTour.count.should be_zero
      days = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]

      ScheduledTour.populate(product, range, days)

      population = ScheduledTour.all
      population.count.should == 10
      population.map(&:date).to_set == range.to_a.to_set

      spot_check = population[3]
      spot_check.product.should == product
      spot_check.cancelled.should be_false
      spot_check.on_the_fly.should be_false
    end

    it "can skip weekends" do
      ScheduledTour.populate(product, range, [:monday, :tuesday, :wednesday, :thursday, :friday])

      population = ScheduledTour.all
      population.count.should == 8
      population.map(&:date).to_set == [first_date,  # W
                                        first_date+1, first_date+2,
                                        first_date+5, first_date+6, first_date+7, first_date+8,
                                        first_date+9].to_set
    end

    it "can include only weekends" do
      ScheduledTour.populate(product, range, [:saturday, :sunday])

      population = ScheduledTour.all
      population.count.should == 2
      population.map(&:date).to_set == [first_date+3, first_date+4]
    end

    it "should object to misspellings" do
      lambda {
        ScheduledTour.populate(product, range, [:saturdy])
      }.should raise_error(Exception, ":saturdy is not a valid day of the week.")
    end

  end

  context 'available on the api' do
    let(:policy) { stub :policy }

    before { ScheduledTourAvailabilityPolicy.stub(:for).and_return(policy) }

    it 'is available if it is not an on the fly tour and it can take reservations' do
      policy.stub(:would_be_within_simultaneous_tour_limit?).and_return(true)
      scheduled_tour = FactoryGirl.create(:scheduled_hiking, on_the_fly: false)
      scheduled_tour.available_on_api?.should be_true
    end

    it 'is not available if it is an on the fly tour' do
      policy.stub(:would_be_within_simultaneous_tour_limit?).and_return(true)
      scheduled_tour = FactoryGirl.create(:scheduled_hiking, on_the_fly: true)
      scheduled_tour.available_on_api?.should be_false
    end

    it 'is not available if it can not take reservations' do
      policy.stub(:would_be_within_simultaneous_tour_limit?).and_return(false)
      scheduled_tour = FactoryGirl.create(:scheduled_hiking, on_the_fly: false)
      scheduled_tour.available_on_api?.should be_false
    end
  end

  it 'can be created as an on the fly tour' do
    product = FactoryGirl.create(:product)
    expect {
      ScheduledTour.create_on_the_fly!(product_id: product.id, date: Date.today)
    }.to change(ScheduledTour.all_on_the_fly, :count).from(0).to(1)
  end
end
