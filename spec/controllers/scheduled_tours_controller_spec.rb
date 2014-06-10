require 'spec_helper'
require 'support/mocks'
require 'support/json'
require 'support/products'

describe ScheduledToursController do

  let(:tour_operator) { FactoryGirl.create :tour_operator }

  before { sign_in tour_operator }

  context "showing a scheduled tour" do
    let(:product)        {
      Product.new { | p |
        p.name = "product name"
        p.description = "product description"
        p.difficulty = "product difficulty"
        p.min_capacity = 2
        p.max_capacity = 9
        p.duration = duration(16)
        p.start_time = time(5, 30)
        p.whats_included = "product what's included"
        p.what_to_bring = "product what to bring"
        p.meeting_point = "product meeting point"
        p.languages = 'product languages'
      }
    }

    let(:scheduled_tour) {
      ScheduledTour.new { | s |
        s.date = Date.new(2012, 7, 3)
        s.product = product
        s.reservations = [reservation, cancelled_reservation]
      }
    }

    let(:reservation) {
      Reservation.new { | r |
        r.id = 33
        r.contact_name = "reservation contact name"
        r.email = "reservation email"
        r.phone = "reservation phone"
        r.number_of_people = 3
        r.comments = "reservation comments"
        r.cancelled = false
      }
    }

    let(:cancelled_reservation) {
      Reservation.new { | r |
        r.id = 88
        r.contact_name = "cancelled reservation contact name"
        r.email = "cancelled reservation email"
        r.phone = "cancelled reservation phone"
        r.number_of_people = 3
        r.comments = "cancelled reservation comments",
        r.cancelled = true
      }
    }

    before do
      ScheduledTour.stub(:find).and_return(scheduled_tour)
    end

    it 'shows product information' do
      get :show, format: 'json', :id => 1
      response_should_be_json_hash_with(product_name: product.name,
                                        description: product.description,
                                        difficulty: product.difficulty,
                                        min_capacity: product.min_capacity,
                                        max_capacity: product.max_capacity,
                                        duration: "16.0",
                                        start_time: "5:30",
                                        whats_included: product.whats_included,
                                        what_to_bring: product.what_to_bring,
                                        meeting_point: product.meeting_point,
                                        languages: product.languages)
    end

    it 'shows reservation information, including the cancelled reservation' do
      get :show, format: 'json', :id => 1
      actual_reservations = response_one_value(:reservations)
      actual_reservations.size.should == 2
      actual_uncancelled_reservation, actual_cancelled_reservation = actual_reservations
      should_be_hash_with(actual_uncancelled_reservation,
                          id: reservation.id,
                          contact_name: reservation.contact_name,
                          email: reservation.email,
                          phone: reservation.phone,
                          number_of_people: reservation.number_of_people,
                          cancelled: false,
                          comments: reservation.comments)
      should_be_hash_with(actual_cancelled_reservation,
                          id: cancelled_reservation.id,
                          contact_name: cancelled_reservation.contact_name,
                          email: cancelled_reservation.email,
                          phone: cancelled_reservation.phone,
                          number_of_people: cancelled_reservation.number_of_people,
                          cancelled: true,
                          comments: cancelled_reservation.comments)
    end

    it 'shows scheduled-tour-specific information' do
      get :show, format: 'json', :id => 1
      response_should_be_json_hash_with(date: "Tuesday, July 3 2012",
                                        number_of_people_signed_up: reservation.number_of_people,
                                        available_spots: 6)
    end

    it 'pegs "spots available" at 0 even if the operator has forced extra people onto the tour' do
      another_reservation = Reservation.new do | r |
        r.number_of_people = 7
      end
      scheduled_tour.reservations << another_reservation
      get :show, format: 'json', :id => 1
      response_should_be_json_hash_with(max_capacity: 9,
                                        number_of_people_signed_up: 10,
                                        available_spots: 0)
    end

    it 'does show cancelled tours and their reservations' do
      scheduled_tour.cancel
      get :show, format: 'json', :id => 1
      response_should_be_json_hash_with(cancelled: true)
      actual_reservations = response_one_value(:reservations)
      actual_reservations.size.should == 2
      actual_reservations[0]["cancelled"].should == true
      actual_reservations[1]["cancelled"].should == true
    end
  end

  it "allows the tour operator to cancel an entire scheduled tour" do
    scheduled_tour = mock(:scheduled_tour, :id => 1)
    during {
      post :cancel, format: 'json', id: scheduled_tour.id
    }.behold! {
      ScheduledTour.should_receive(:find).with(scheduled_tour.id).and_return(scheduled_tour)
      scheduled_tour.should_receive(:contact_information).and_return([{:contact => :information}])
      scheduled_tour.should_receive(:cancel)
    }
    parsed_response_body[0].should == {'contact' => 'information'}
  end

  context 'creating on the fly tours' do
    let(:product) { FactoryGirl.create(:hiking, max_capacity: 10, tour_operator: tour_operator) }

    let(:date) { Date.new(2012, 8, 1) }
    let(:tour_info) do
      {
        product_id: product.id,
        date: date.to_s(:db),
        reservation: {
          contact_name: "Fred",
          email: 'fred@gmail.com',
          number_of_people: 4,
          phone: '09 4444 555',
          comments: 'Something else',
        }
      }
    end

    before { controller.stub(:current_tour_operator).and_return(tour_operator) }

    shared_examples_for 'successful on the fly tour creation' do
      it 'schedules a new tour on the fly' do
        expect {
          post :create, sent_parameters
        }.to change(ScheduledTour.all_on_the_fly, :count).from(0).to(1)
      end

      it 'creates a reservation for the new tour' do
        expect {
          post :create, sent_parameters
        }.to change(Reservation, :count).from(0).to(1)
      end

      it "returns the scheduled tour's json" do
          post :create, sent_parameters
          response_should_be_json_hash_with(date: "Wednesday, August 1 2012",
                                            number_of_people_signed_up: 4,
                                            available_spots: 6)
      end
    end

    context "max capacity for a reservation" do 
      context 'is not exceeded'  do 
        let(:sent_parameters) { tour_info }
        before { tour_operator.stub(:can_handle_a_new_tour?).and_return(true) }
        it_behaves_like 'successful on the fly tour creation'
      end

      context 'is exceeded' do
        it 'returns an error if the tour will put the tour operator overcapacity' do
          tour_operator.stub(:can_handle_a_new_tour?).with(product, date).and_return(true)
          tour_info[:reservation][:number_of_people] = product.max_capacity+1

          post :create, tour_info
          response.status.should be 406
          response_should_be_json_hash_with(error: "Not enough room",
                                            room_available: product.max_capacity)
        end
      end

      context 'is exceeded but the request says to ignore that' do
        let(:sent_parameters) { tour_info.merge(override_capacity: true) }
        before { tour_operator.stub(:can_handle_a_new_tour?).with(product, date).and_return(false) }
        it_behaves_like 'successful on the fly tour creation'
      end
    end

    context "simultaneous tours" do 
      context 'cause no capacity issues'  do
        let(:sent_parameters) { tour_info }
        before { tour_operator.stub(:can_handle_a_new_tour?).and_return(true) }
        it_behaves_like 'successful on the fly tour creation'
      end

      context 'cause capacity issues' do
        it 'returns an error if the tour will put the tour operator overcapacity' do
          tour_operator.stub(:can_handle_a_new_tour?).with(product, date).
                             and_return(false)
          post :create, tour_info
          response.status.should be 406
          response_should_be_json_hash_with(error: "Too many tours on this day already have reservations")
        end
      end

      context 'would cause capacity issues but request says to ignore them' do
        let(:sent_parameters) { tour_info.merge(override_capacity: true) }
        before { tour_operator.stub(:can_handle_a_new_tour?).with(product, date).and_return(false) }
        it_behaves_like 'successful on the fly tour creation'
      end
    end


  end
end
