require 'spec_helper'
require 'support/json'
require 'set'

describe Api::ScheduledToursController do
  let(:sales_channel)    { FactoryGirl.create(:atrapalo) }

  def request_params(request_specific_info)
    request_specific_info.merge(api_key: sales_channel.api_key)
  end

  context "search interface" do
    ## Happy path is tested via end-to-end cucumber test.

    it "knows how to complain about errors" do
      get :search, request_params(first_date: "2012-03-04")
      response.status.should == 406
    end
  end
end
