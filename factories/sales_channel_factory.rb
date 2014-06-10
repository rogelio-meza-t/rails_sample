#encoding: utf-8

FactoryGirl.define do
  factory :atrapalo, class: SalesChannel do
    name                 'Atrápalo si puedes'
    contact_email        'cristobal.m@atrapalo.com'
    contact_name         'Cristóbal Gracia'
    authentication_token 'xxxxxxxxxxxxxxxxxxx'
  end
end
