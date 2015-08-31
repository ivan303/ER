FactoryGirl.define do
  factory :schedule do
		weekday "Mon"
		begins_at DateTime.new(2015,8,30,10,0,0) 
		ends_at DateTime.new(2015,8,30,16,30,0)
  end

end
