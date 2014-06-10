require 'calendar'

class Reservation; end

describe Calendar do
  subject             { Calendar.of tour_operator }
  let(:tour_operator) { stub :tour_operator }

  it 'belongs to a tour operator' do
    subject.owner.should be tour_operator
  end

  it 'knows the reserved dates the tour operator has' do
    scheduled_tour1 = stub(:tour1, date: Date.new(2012, 12, 20))
    reservation1 = stub(:reservation1, scheduled_tour: scheduled_tour1 )
    scheduled_tour2 = stub(:tour1, date: Date.new(2013, 1, 2))
    reservation2 = stub(:reservation2, scheduled_tour: scheduled_tour2)

    date_range = Date.new(2012, 12)...Date.new(2013, 2)
    Reservation.stub(:for).with(tour_operator, date_range).
      and_return([reservation1, reservation2])
    dates_info = { 'start_month' => '12', 'start_year' => '2012', 'months' => 2 }

    subject.reserved_dates(dates_info).
      should include({date: Date.new(2012, 12, 20)}, {date: Date.new(2013, 1, 2)})
  end

end
