module JsonSupport
  # TODO: Make this an rspec matcher?
  def response_should_be_json_hash_with(expected)
    should_be_hash_with(parsed_response_body, expected)
  end

  def response_one_value(key)
    parsed_response_body[key.to_s]
  end

  def should_be_hash_with(actual, expected)
    expected.each do | key, value |
      actual[key.to_s].should == value
    end
  end

  def parsed_response_body
    JSON.parse(response.body)
  end
end

# This rigamarole with a module is needed to avoid
# having the methods end up as privates called from
# a different scope. 
include JsonSupport

RSpec::Matchers.define :be_json_with do |expected_json|
  match do |response|
    @result = JSON.parse(response.body)
    @result == expected_json
  end

  failure_message_for_should do |response|
    "expected #{response.body} to be parsed to #{expected_json} but was parsed to #{@result}"
  end
end
