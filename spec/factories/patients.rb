FactoryGirl.define do
  factory :patient do
    email { Faker::Internet.email }
    password "12345678"
    firstname "Paul"
    lastname "McCartney"
    pesel "93022009056"
  end
end