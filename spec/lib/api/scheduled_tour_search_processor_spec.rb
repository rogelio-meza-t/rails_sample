require 'api/scheduled_tour_search_processor'

describe Api::ScheduledToursSearchRequest do
  it "will accepts correct parameters" do
    params = {"first_date" => "2036-11-11", "last_date_inclusive" => "2036-11-13"}
    subject = Api::ScheduledToursSearchRequest.new(params, :irrelevant)
    subject.should be_valid
    subject.date_range.should == (Date.new(2036, 11, 11)..Date.new(2036, 11, 13))
    subject.date_range.exclude_end?.should be_false
  end

  context "adjusting dates" do

    before do 
      Date.should_receive(:today).and_return(Date.new(2036, 11, 11))
    end

    it "silently adjusts a search for tours starting in the past" do
      params = {"first_date" => "2036-11-10", "last_date_inclusive" => "2036-11-18"}
      subject = Api::ScheduledToursSearchRequest.new(params, :irrelevant)
      subject.should be_valid
      subject.date_range.should == (Date.new(2036, 11, 13)..Date.new(2036, 11, 18))
    end

    it "silently adjusts a search for tours starting with today" do
      params = {"first_date" => "2036-11-11", "last_date_inclusive" => "2036-11-18"}
      subject = Api::ScheduledToursSearchRequest.new(params, :irrelevant)
      subject.should be_valid
      subject.date_range.should == (Date.new(2036, 11, 13)..Date.new(2036, 11, 18))
    end

    it "silently adjusts a search for tours starting with tomorrow" do
      params = {"first_date" => "2036-11-12", "last_date_inclusive" => "2036-11-18"}
      subject = Api::ScheduledToursSearchRequest.new(params, :irrelevant)
      subject.should be_valid
      subject.date_range.should == (Date.new(2036, 11, 13)..Date.new(2036, 11, 18))
    end

    it "accepts searches for two days hence" do
      params = {"first_date" => "2036-11-13", "last_date_inclusive" => "2036-11-13"}
      subject = Api::ScheduledToursSearchRequest.new(params, :irrelevant)
      subject.should be_valid
      subject.date_range.should == (Date.new(2036, 11, 13)..Date.new(2036, 11, 13))
    end
  end

  it "will fail on missing args" do
    subject = Api::ScheduledToursSearchRequest.new({"first_date" => "2036-11-11"}, :irrelevant)
    subject.should_not be_valid
    subject.error_message.should == "You must provide these parameters: first_date and last_date_inclusive."
  end

  it "will fail on improperly-formatted dates" do
    subject = Api::ScheduledToursSearchRequest.new({"first_date" => "broken",
                                                    "last_date_inclusive" => "2036-11-11"}, :irrelevant)
    subject.should_not be_valid
    subject.error_message.should == "Your dates are incorrectly formatted."

    subject = Api::ScheduledToursSearchRequest.new({"first_date" => "2036-11-11",
                                                    "last_date_inclusive" => "broken"}, :irrelevant)
    subject.should_not be_valid
    subject.error_message.should == "Your dates are incorrectly formatted."
  end

end


describe Api::ScheduledToursSearchProcessor do

  let(:controller) { mock(:controller) }
  let(:processor) { Api::ScheduledToursSearchProcessor.new(controller) } 
  default_tour_properties = { cancelled: false, full?: false, on_the_fly?: false }

  class NullExhibit
    def as_hashes(anything); anything; end
  end

  class AllTourConflicts 
    def self.filter(tours)
      []
    end
  end

  it "obeys a tour operator's availability policy when choosing tours to format" do

    accepting_operator = mock(:tour_operator)
    rejecting_operator = mock(:tour_operator)

    accepted_tour = stub(default_tour_properties.merge(tour_operator: accepting_operator))
    rejected_tour = stub(default_tour_properties.merge(tour_operator: rejecting_operator))

    processor.exhibit = NullExhibit.new
    during {
      processor.result_from_tours([accepted_tour, rejected_tour])
    }.behold!{
      ScheduledTourAvailabilityPolicy.should_receive(:for).with(accepting_operator).
                                      and_return(ScheduledTourAvailabilityPolicy::NoTourConflicts)
      ScheduledTourAvailabilityPolicy.should_receive(:for).with(rejecting_operator).
                                      and_return(AllTourConflicts)
    }
    @result.should == [accepted_tour]
  end

  context "handling special kinds of tours:" do 
    context "cancelled tours" do
      let (:tour) { stub(default_tour_properties.merge(cancelled: true)) }
      
      it "are not returned" do
        actual = processor.result_from_tours([tour])
        actual.should be_empty
      end

      it "do not influence availability" do
        during {
          processor.result_from_tours([tour])
        }.behold! {
          ScheduledTourAvailabilityPolicy.should_receive(:for).never
        }
      end
    end

    # Not needed for previous spec
    let (:accepting_operator) { stub(scheduled_tour_availability_policy: :all_tours_are_available,
                                     scheduled_tour_availability_policy_parameters: nil) }

    def policy_that_expects_tours(expected)
      policy = Object.new
      policy.define_singleton_method(:filter) { | tours |
        tours.should == expected
        tours
      }
      policy
    end

    context "on-the-fly tours:" do
      let (:tour) { stub(default_tour_properties.merge(tour_operator: accepting_operator,
                                                       on_the_fly?: true)) }
      
      it "are not returned" do
        actual = processor.result_from_tours([tour])
        actual.should be_empty
      end

      it "influence availability" do
        during {
          processor.result_from_tours([tour])
        }.behold! {
          ScheduledTourAvailabilityPolicy.should_receive(:for).with(accepting_operator).
                                          and_return(policy_that_expects_tours([tour]))
        }
      end
    end

    context "tours that are full:" do
      let (:tour) { stub(default_tour_properties.merge(tour_operator: accepting_operator, 
                                                  full?: true)) }

      it "are not returned" do
        actual = processor.result_from_tours([tour])
        actual.should be_empty
      end

      it "influence availability" do
        during {
          processor.result_from_tours([tour])
        }.behold! {
          ScheduledTourAvailabilityPolicy.should_receive(:for).with(accepting_operator).
                                          and_return(policy_that_expects_tours([tour]))
        }
      end
    end
  end
end

describe Api::ScheduledToursSearchExhibit do
  let(:operator)  {
    stub(name: "matching",
         address: "matching address",
         phone: "matching phone",
         email: 'matching@tours.com',
         contact_person: "matching contact person",
         description: "matching description",
         logo: "a url")
  }

  let(:product) {
    stub(name: "product name",
         start_time: time(8, 30),
         location: "product location",
         meeting_point: "product meeting point",
         price_in_local_units: 29999,
         
         description: "product description",
         whats_included: "product what's included",
         what_to_bring: "product what to bring",
         difficulty: "product difficulty",
         languages: "product languages",
         product_images: [stub(url: "product image url")],
         min_capacity: "product min capacity",
         max_capacity: "product max capacity",
         meeting_point: "product meeting point",
         duration: "product duration")
  }

  let(:later_tour) {
    stub(id: 33,
         date: Date.new(2012, 11, 24),
         tour_operator: operator,
         product: product,
         room_available: "later tour room available")
  }

  let(:earlier_tour) {
    stub(id: 993,
         date: Date.new(2012, 3, 4),
         tour_operator: operator,
         product: product,
         room_available: "earlier tour room available")
  }

  it "produces an array of hashes to render to user of API"do
    actual = subject.as_hashes([earlier_tour])
    actual.count.should == 1

    actual.first.should == {
      tour_operator: {
        name: "matching",
        address: "matching address",
        phone: "matching phone",
        email: "matching@tours.com",
        contact_person: "matching contact person",
        description: "matching description",
        logo_url: "a url"
      },
      product_name: "product name",
      date: '2012-03-04',
      local_price_string: "CLP29.999",
      
      location: "product location",
      description: "product description",
      whats_included: "product what's included",
      what_to_bring: "product what to bring",
      difficulty: "product difficulty",
      languages: "product languages",
      image_urls: ["product image url"],
      
      min_capacity: "product min capacity",
      max_capacity: "product max capacity",
      room_available: "earlier tour room available",
      
      meeting_point: "product meeting point",
      start_time: "8:30",
      duration: "product duration",
      scheduled_tour_id: 993
    }
  end

  it "sorts the results" do 
    actual = subject.as_hashes([later_tour, earlier_tour])
    actual.count.should == 2
    actual[0][:date].should == '2012-03-04'
    actual[1][:date].should == '2012-11-24'
  end

end
