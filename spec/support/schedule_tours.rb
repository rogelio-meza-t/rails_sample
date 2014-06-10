def schedule(product_factory, tour_operator, date)
  product = FactoryGirl.create product_factory, tour_operator: tour_operator
  FactoryGirl.create :scheduled_tour, product: product, date: date
end
