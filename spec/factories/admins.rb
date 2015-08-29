FactoryGirl.define do
  factory :admin, class: Admin, parent: :user do
  	role 'Admin'
  end
end