require 'rails_helper'

describe Patient do
	before(:each) { @patient = FactoryGirl.create(:patient) }

	subject { @patient }

	it { should validate_presence_of(:pesel) }
	it { should validate_absence_of(:pwz) }
	it { should allow_value('39106783143').for(:pesel) }
	it { should_not allow_value('2905894320', '290575119301', '31905-93015', 'aoginedhiod').for(:pesel) }
	it { expect(@patient.role).to match 'Patient' }
	it { expect(@patient.pwz).to be nil }

end