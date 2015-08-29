FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "12345678"
    firstname "Bob"
    lastname "Dylan"
  end
end
