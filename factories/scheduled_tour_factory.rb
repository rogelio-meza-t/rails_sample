FactoryGirl.define do

  factory :scheduled_tour do
    association :product, factory: :product
    date    Date.today
  end

  factory :scheduled_rafting_morning, class: ScheduledTour do
    association :product, factory: :rafting_morning
    date    Date.today
  end

  factory :scheduled_rafting_afternoon, class: ScheduledTour do
    association :product, factory: :rafting_afternoon
    date    Date.today
  end

  factory :scheduled_hiking, class: ScheduledTour do
    association :product, factory: :hiking
    date    Date.today
  end

end
