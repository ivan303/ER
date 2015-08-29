require 'rails_helper'

describe Doctor do
	before(:each) { @doctor = FactoryGirl.create(:doctor) }

	subject { @doctor }

	it { should validate_presence_of(:pwz) }
	it { should validate_absence_of(:pesel) }
	it { should allow_value('3910678').for(:pwz) }
	it { should_not allow_value('290583', '29057511', '5-93015', 'nedhiod').for(:pesel) }
end