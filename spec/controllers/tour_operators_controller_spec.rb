require 'spec_helper'

describe TourOperatorsController do
  let(:tour_operator) { FactoryGirl.create :tour_operator }
  before { sign_in tour_operator }

  it "returns tour operator's reservation calendar" do
    dates = [{date: Date.today}, {date:Date.yesterday}]
    calendar = stub(:calendar)
    Calendar.stub(:of).with(tour_operator).and_return(calendar)
    calendar.stub(:reserved_dates).and_return(dates)
    get 'dates', format: 'json', start_month: 7, start_year: 2012, months: 3
    response.body.should eq dates.to_json
  end

  it "returns tour operator's catalog" do
    catalogs_json = [{date:'123455667', product:{name: 'rafting'}}].to_json
    catalog = stub(:catalog, to_json: catalogs_json)
    Catalog.stub(:of).with(tour_operator, nil).and_return(catalog)
    get 'catalog', format: 'json'
    response.body.should eq catalogs_json
  end

  it "returns tour operator's catalog for a particular day" do
    day = '2012-07-21T07:59:20Z'
    catalogs_json = [{datetime: day, product:{name: 'rafting'}}].to_json
    catalog = stub(:catalog, to_json: catalogs_json)
    Catalog.stub(:of).with(tour_operator, day).and_return(catalog)
    get 'catalog', format: 'json', date: day
    response.body.should eq catalogs_json
  end

  it "returns tour operator's products" do
    hiking = FactoryGirl.create(:hiking, tour_operator: tour_operator)
    products = [hiking]
    Product.stub(:offered_by).with(tour_operator).and_return(products)
    get :products, id: 11
    response.body.should eq [hiking].to_json
  end

end
