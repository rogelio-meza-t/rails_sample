def reserve(tour_operator, date)
  product        = FactoryGirl.create :product, tour_operator: tour_operator
  scheduled_tour = FactoryGirl.create :scheduled_tour, product: product, date: date
  reservation    = FactoryGirl.create :reservation, scheduled_tour: scheduled_tour
end
