require 'spec_helper'
require 'support/mocks'
require 'support/json'
require 'support/tour_operator'

describe ReservationsController do
  let(:reservation)    { mock(:reservation, id: 5) }
  let(:tour_operator) { FactoryGirl.create :tour_operator }
  let(:scheduled_tour) { mock(:scheduled_tour, id: 1, tour_operator: tour_operator) }

  before do
    sign_in tour_operator
    controller.stub(:current_tour_operator).and_return(tour_operator)
  end

  context "normal reservation creation" do
    let(:policy) { mock(:availability_policy) }
    let(:reservation_data) { { 
        'scheduled_tour_id' => scheduled_tour.id,
        'number_of_people' => 20
      }}

    before do
      ScheduledTour.stub(:find).with(scheduled_tour.id).and_return(scheduled_tour)
      tour_operator.should_receive(:tour_availability_policy).and_return(policy)
    end

    it 'returns the newly created reservation id' do
      during {
        post :create, format: 'json', reservation: reservation_data
      }.behold! {
        policy.should_receive(:must_be_within_simultaneous_tour_limit).with(scheduled_tour).
               and_return(Success(true))
        scheduled_tour.should_receive(:must_have_room_for).with(20).
                       and_return(Success(true))
        Reservation.should_receive(:create).with(reservation_data).and_return(reservation)
      }
      response_should_be_json_hash_with(id: reservation.id)
    end

    it 'returns an error when too many people in reservation' do
      during {
        post :create, format: 'json', reservation: reservation_data
      }.behold! {
        scheduled_tour.should_receive(:must_have_room_for).with(20).
               and_return(Failure({error: "message"}))
        policy.should_receive(:must_be_within_simultaneous_tour_limit).at_most(:once).
               with(scheduled_tour).
               and_return(Success(true))
      }
      response_should_be_json_hash_with(error: "message")
      response.status.should == 406
    end

    it 'returns an error when there would be a conflict with another tour' do
      during {
        post :create, format: 'json', reservation: reservation_data
      }.behold! {
        policy.should_receive(:must_be_within_simultaneous_tour_limit).
               with(scheduled_tour).
               and_return(Failure({error: "message"}))
        scheduled_tour.should_receive(:must_have_room_for).with(20).at_most(:once).
               and_return(Success(true))
      }
      response_should_be_json_hash_with(error: "message")
      response.status.should == 406
    end
  end

  it "can force a reservation, bypassing checking" do 
    during {
      post :force_create, format: 'json', reservation: "reservation data"
    }.behold! {
      Reservation.should_receive(:create).with("reservation data").and_return(reservation)
    }
    response_should_be_json_hash_with(id: reservation.id)
  end

  it "allows a reservation to be canceled by id" do
    reservation = mock(:reservation, :id=>5)
    during {
      post :cancel, format: 'json',  id: '5'
    }.behold! {
      Reservation.should_receive(:find).with('5').and_return(reservation)
      reservation.should_receive(:cancel)
      reservation.should_receive(:save!)
    }
    response_should_be_json_hash_with(id: reservation.id)
  end
end
