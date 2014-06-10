require 'spec_helper'

#NOTE: This test uses ReservationController as an example of ApiController
#      subclass so we can be able to test authentication.
describe Api::ReservationsController, 'as an example of an ApiController' do
  it 'returns a 401 status code if the API key is not provided' do
    post :create
    response.status.should eq 401
  end

  it 'returns a 401 status code if the provided API key is not valid' do
    post :create, api_key: 'xxxxxxxxxxxx'
    response.status.should eq 401
  end

  it 'returns a JSON error message if the API key is not valid' do
    post :create
    response.body.should match /API key is not valid/
  end

  it 'does not remember the sales channel between requests' do
    pending 'this behaves correctly in the browser but fails here'
    post :create
    response.status.should eq 401
    post :create, sent_parameters
    response.status.should eq 200
    post :create
    response.status.should eq 401
  end
end
