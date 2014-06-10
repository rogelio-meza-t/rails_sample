require 'spec_helper'
require 'support/json'

describe Api::ReservationsController do
  let(:sent_parameters)  { reservation_info.merge(api_key: sales_channel.api_key) }
  let(:sales_channel)    { FactoryGirl.create(:atrapalo) }
  let(:scheduled_tour)   { FactoryGirl.create(:scheduled_hiking) }
  let(:reservation_info) do
    {
      scheduled_tour_id: scheduled_tour.id,
      name: 'Javier Acero',
      email: 'javier@path11.com' ,
      phone: '0034 666 77 88 99',
      group_size: 4,
      comments: 'Vegetarian food please'
    }
  end

  it 'creates a new reservation if the provided information is valid' do
    expect {
      post :create, sent_parameters
    }.to change(sales_channel.reservations, :count).from(0).to(1)
  end

  it 'responds with status 200' do
    post :create, sent_parameters
    response.status.should be 200
  end

  it "returns the reservation reference in the response's JSON" do
    reservation = stub(:reservation, reference: 2011)
    Reservation.stub(:create!).and_return(reservation)
    post :create, sent_parameters
    response.should be_json_with('reservation' => {'confirmation_number' => 2011})
  end

  shared_examples_for 'reservation request with errors' do
    let(:parameters) { sent_parameters }

    it 'does not fulfill the reservation' do
      expect {
        post :create, parameters
      }.not_to change(sales_channel.reservations, :count).from(0).to(1)
    end

    it 'responds with status 406' do
      post :create, parameters
      response.status.should be 406
    end

    it 'returns an error message' do
      post :create, parameters
      response.body.should match /{\s*"error"\s*:\s*"[,|\w|\s]+#{param_name}[,|\w|\s]*"\s*}/
    end
  end

  context 'a reservation request without the name' do
    let(:param_name) { 'name' }
    before { parameters.delete(:name) }
    it_behaves_like 'reservation request with errors'
  end

  context 'a reservation request without the email' do
    let(:param_name) { 'email' }
    before { parameters.delete(:email) }
    it_behaves_like 'reservation request with errors'
  end

  context 'a reservation request without the group_size' do
    let(:param_name) { 'group_size' }
    before { parameters.delete(:group_size) }
    it_behaves_like 'reservation request with errors'
  end

  context 'a reservation request without the scheduled_tour_id' do
    let(:param_name) { 'scheduled_tour_id' }
    before { parameters.delete(:scheduled_tour_id) }
    it_behaves_like 'reservation request with errors'
  end

  context 'a reservation of a scheduled tour that does not exist' do
    let(:param_name) { :scheduled_tour_id }
    before { parameters[:scheduled_tour_id] = -11 }
    it_behaves_like 'reservation request with errors'
  end

  context 'a reservation of a scheduled tour that is cancelled' do
    let(:param_name) { :scheduled_tour_id }
    before { scheduled_tour.cancel }
    it_behaves_like 'reservation request with errors'
  end

  context 'a reservation for a tour without enough room' do
    let(:param_name) { :group_size }
    before { parameters[:group_size] = scheduled_tour.room_available + 1 }
    it_behaves_like 'reservation request with errors'
  end

  context 'on a system failure' do
    before { Reservation.stub(:create!).and_raise('error') }

    it 'does not fulfill the reservation' do
      expect {
        post :create, sent_parameters
      }.not_to change(sales_channel.reservations, :count).from(0).to(1)
    end

    it 'responds with status 500' do
      post :create, sent_parameters
      response.status.should be 500
    end

    it 'returns an error message' do
      post :create, sent_parameters
      response.body.should match /{\s*"error"\s*:\s*"[\w|\s]+unexpected error"\s*}/
    end
  end
end
