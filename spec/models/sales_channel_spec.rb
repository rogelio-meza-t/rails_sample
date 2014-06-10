require 'spec_helper'

describe SalesChannel do
  let(:sales_channel) { FactoryGirl.create :atrapalo }

  it 'has an API key' do
    sales_channel.api_key.should eq sales_channel.authentication_token
  end
end
