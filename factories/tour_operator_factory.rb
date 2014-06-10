#encoding: utf-8

FactoryGirl.define do
  factory :tour_operator do
    email 'tours@gmail.com'
    password 'xxxxxxxx'
  end

  factory :cajon_del_maipo_tours, class: TourOperator do
    email                 'tours.maipo@gmail.com'
    password              '123456'
    password_confirmation '123456'
    name                  'Cajón del Maipo Tours'
    address               'Avenida del Sauce 33, Cajón del Maipo, Chile'
    phone                 '09-9321-4567'
    contact_person        'Cristóbal'
    description           'Cosas sobre el Cajón del Maipo Tours'
  end
end
