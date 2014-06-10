FactoryGirl.define do

  factory :product do
    name :random_product
  end

  factory :rafting_morning, class: Product do
    name           'Rafting the Maipo'
    description    'Rafting in Cajon del Maipo in the morning'
    difficulty     'Easy. Beginners are welcome'
    duration       "1.5"
    languages      'english, spanish'
    max_capacity   20
    what_to_bring  'Will to get wet. Clothes for swimming'
    whats_included 'Guide, all the equipment and gift'
    start_time     '09:00'

    factory :rafting_afternoon, class: Product do
      description 'Rafting in Cajon del Maipo in the afternon'
      max_capacity 12
    start_time     '17:00'
    end
  end


  factory :hiking, class: Product do
    name           'Hiking in a Volcano'
    description    'Hiking Cajon del Maipos volcano a whole day'
    difficulty     'Medium. Some of the paths are difficult to cross'
    duration       "3.5"
    languages      'english, spanish, french, german'
    max_capacity   8
    what_to_bring  'Comfortable shoes. Sun glasses.'
    whats_included 'Guide and food.'
    start_time     '10:00'
  end

end
