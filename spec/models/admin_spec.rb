require 'rails_helper'

describe Admin do
	before(:each) { @admin = FactoryGirl.create(:admin) }

	subject { @admin }

	it { should validate_absence_of(:pesel) }	
	it { should validate_absence_of(:pwz) }
	it { expect(@admin.role).to match 'Admin' }

end
