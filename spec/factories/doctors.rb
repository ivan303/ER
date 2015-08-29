FactoryGirl.define do
	factory :doctor, class: Doctor, parent: :user do
		pwz "1234567"
	end
end