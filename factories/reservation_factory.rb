FactoryGirl.define do
  factory :reservation do
    contact_name     'Fred'
    email            'fred@gmail.com'
    number_of_people 4
    phone            '09 4445 333'
    comments         'Vegetarian food required'
  end
end
