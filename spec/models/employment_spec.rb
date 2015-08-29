require 'rails_helper'

describe Employment do
	before do
		@doctor = FactoryGirl.create(:doctor)
		@clinic = FactoryGirl.create(:clinic)
		@employment = FactoryGirl.create(:employment, doctor_id: @doctor.id, clinic_id: @clinic.id)
	end

	it 'should not create employment identical as existing one' do
		empl = Employment.new(clinic_id: @clinic.id, doctor_id: @doctor.id)
		expect(empl).not_to be_valid
	end

	it 'should create employment with the same user but another clinic' do
		cli = FactoryGirl.create(:clinic)
		empl = Employment.new(clinic_id: cli.id, doctor_id: @doctor.id)
		expect(empl).to be_valid
	end
end
