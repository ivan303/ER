FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "12345678"
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
  end
end
