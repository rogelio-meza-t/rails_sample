describe ReservationsController do
  let(:tour_operator) { FactoryGirl.create :tour_operator, operator_can_do_only_n_simultaneous_tours(1) }

  before do
    sign_in tour_operator
  end

  context "in cases that would conflict with the simultaneous tours policy" do
    let(:product) { FactoryGirl.create(:product, start_time: time(8), duration: 8, max_capacity: 8, tour_operator: tour_operator) }
    let(:tour1) { FactoryGirl.create(:scheduled_tour, product: product, date: Date.today) } 
    let(:tour2) { FactoryGirl.create(:scheduled_tour, product: product, date: Date.today) } 

    let(:base_reservation) {{
      'scheduled_tour_id' => tour2.id,
      'contact_name' => "fred",
      'email' => "email@email.com",
      "phone" => "34343",
      "comments" => "none",
      'number_of_people' => '2'
      }}
    
    it 'returns an error' do
      FactoryGirl.create(:reservation, scheduled_tour: tour1)
      post :create, format: 'json', reservation: base_reservation
      response_should_be_json_hash_with(error: "Too many tours on this day already have reservations")
      response.status.should == 406
    end
  
    it 'returns an error' do
      reservation_data = base_reservation.merge('number_of_people' => 200)
      post :create, format: 'json', reservation: reservation_data
      response_should_be_json_hash_with(error: "Not enough room")
      response.status.should == 406
    end
  

    it 'returns success' do
      post :create, format: 'json', reservation: base_reservation
      response.status.should == 200
      Reservation.find(JSON.parse(response.body)["id"]).should_not be_nil
    end
  end
end
