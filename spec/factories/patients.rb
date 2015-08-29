FactoryGirl.define do
  factory :patient, class: Patient, parent: :user do
    pesel "93022009056"
  end
end