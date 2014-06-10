require 'catalog'
require 'date'

class ScheduledTour; end

describe Catalog do
  subject             { Catalog.of tour_operator }
  let(:tour_operator) { stub :tour_operator }
  let(:tour1)         { stub :tour1 }
  let(:tour2)         { stub :tour2 }

  it 'belongs to a tour operator' do
    Catalog.of(tour_operator).owner.should be tour_operator
  end

  it 'knows the catalog of scheduled products of the owner' do
    ScheduledTour.stub(:upcoming_of).with(tour_operator).and_return([tour1, tour2])
    subject.scheduled_tours.should include(tour1, tour2)
  end

  it 'knows the catalog for a particular day' do
    date_string = '2012-07-30T07:59:20Z'
    date = Date.new(2012, 7, 30)
    ScheduledTour.stub(:on_date_of).with(date, tour_operator).and_return([tour2])
    Catalog.of(tour_operator, date_string).scheduled_tours.should include(tour2)
  end

  it 'can be represented as JSON' do
    upcoming_tours = [tour1, tour2]
    upcoming_tours_as_json = '[{some_key: "some value"}]'
    ScheduledTour.stub(:upcoming_of).and_return(upcoming_tours)
    upcoming_tours.stub(:to_json).and_return(upcoming_tours_as_json)
    subject.to_json.should eq upcoming_tours_as_json
  end
end
