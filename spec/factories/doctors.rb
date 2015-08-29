FactoryGirl.define do
	factory :doctor do
		email { Faker::Internet.email }
		password "12345678"
		firstname "John"
		lastname "Lennon"
		pwz "1234567"
	end
end