require 'spec_helper'
require 'support/schedule_tours'

describe TourOperator do
  let(:tour_operator) { FactoryGirl.create :tour_operator }

  it 'knows his tours for a particular date' do
    today, tomorrow = Date.today, Date.tomorrow
    scheduled_today    = schedule(:rafting_morning, tour_operator, today)
    scheduled_tomorrow = schedule(:rafting_morning, tour_operator, tomorrow)
    tour_operator.tours_on(today).should include(scheduled_today)
    tour_operator.tours_on(today).should_not include(scheduled_tomorrow)
  end

  it "knows its own tour availability policy" do 
    tour_operator.scheduled_tour_availability_policy = 'all_tours_are_available'
    tour_operator.scheduled_tour_availability_policy_parameters = {}.to_json

    tour_operator.tour_availability_policy.should == ScheduledTourAvailabilityPolicy.all_tours_are_available({})
  end

  it 'knows if a tour will put him over capacity' do
    tour_operator.scheduled_tour_availability_policy = 'only_n_simultaneous_tours'
    tour_operator.scheduled_tour_availability_policy_parameters = {n: 1}.to_json
    tour_operator.save!
    today = Date.today
    scheduled_hiking = schedule(:hiking, tour_operator, today)
    hiking = scheduled_hiking.product
    tour_operator.can_handle_a_new_tour?(hiking, today).should be_true
  end
end
