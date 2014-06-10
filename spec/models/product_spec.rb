require 'spec_helper'
require 'support/products'

describe Product do
  it 'knows the products of a tour operator' do
    tour_operator1 = FactoryGirl.create(:tour_operator)
    tour_operator2 = FactoryGirl.create(:tour_operator, email: 'other@a.es')
    hiking  = FactoryGirl.create :hiking, tour_operator: tour_operator1
    rafting = FactoryGirl.create :hiking, tour_operator: tour_operator2
    Product.offered_by(tour_operator1).should include(hiking)
    Product.offered_by(tour_operator1).should_not include(rafting)
  end

  it "can return a non-inclusive time range" do
    product = Product.new(start_time: time(8, 30),
                          duration: duration("1.5"))

    time_range = product.time_range
    time_range.should == (time(8,30)...time(10))
    time_range.exclude_end?.should == true
  end
end
