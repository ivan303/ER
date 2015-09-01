require 'rails_helper'

describe Appointment do

	it { should validate_presence_of(:schedule_id) }
	it { should validate_presence_of(:patient_id) }
	it { should validate_presence_of(:begins_at) }
	it { should validate_presence_of(:ends_at) }

	it { should allow_value('2015-08-30 14:00:00', '2015-08-31 15:30:00').for(:begins_at) }
	it { should allow_value('2015-08-30 20:00:00', '2015-08-31 15:30:00').for(:ends_at) }

	before(:each) do
		@patient = FactoryGirl.create(:patient)
		@clinic = FactoryGirl.create(:clinic)
		@doctor = FactoryGirl.create(:doctor)
		@employment = Employment.create(doctor_id: @doctor.id, clinic_id: @clinic.id)
		@schedule = FactoryGirl.create(:schedule, employment_id: @employment.id,
			begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,9,1,12,0,0))
	end

	# test if doctor is free in visit time
	it "visit in this time already exists" do
		patient2 = FactoryGirl.create(:patient)
		appointment1 = Appointment.create( {schedule_id: @schedule.id, patient_id: @patient.id,
			begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,9,1,10,30,0)} )
		appointment2 = Appointment.new( {schedule_id: @schedule.id, patient_id: patient2.id,
			begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,9,1,10,30,0)} )
		appointment2.valid?
		expect(appointment2.errors[:visit]).to include "doctor has visit in this time"
	end

	context "visit in this time doesn't exist" do
		it "the same day, different hour" do
			patient2 = FactoryGirl.create(:patient)
			appointment1 = Appointment.create( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,9,1,10,30,0)} )
			appointment2 = Appointment.new( {schedule_id: @schedule.id, patient_id: patient2.id,
				begins_at: DateTime.new(2015,9,1,10,30,0), ends_at: DateTime.new(2015,9,1,11,00,0)} )
			appointment2.valid?
			expect(appointment2.errors[:visit].empty?)
		end

		it "the same hour, different day" do
			patient2 = FactoryGirl.create(:patient)
			appointment1 = Appointment.create( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,9,1,10,30,0)} )
			appointment2 = Appointment.new( {schedule_id: @schedule.id, patient_id: patient2.id,
				begins_at: DateTime.new(2015,9,8,10,0,0), ends_at: DateTime.new(2015,9,8,10,30,0)} )
			appointment2.valid?
			expect(appointment2.errors[:visit].empty?)
		end
	end


	# test if doctor works in clinic in visit date (weekday and working hours)
	context "doctor doesn't work in clinic in visit time" do

		it "wrong day" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,2,10,0,0), ends_at: DateTime.new(2015,9,2,10,30,0)} )
			appointment.valid?
			expect(appointment.errors[:visit]).to include "doctor doesn't work in clinic that day"
		end

		it "wrong hours - to early" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,9,59,0), ends_at: DateTime.new(2015,9,1,10,30,0)})
			appointment.valid?
			expect(appointment.errors[:visit]).to include "doctor doesn't work in clinic in that time"
		end

		it "wrong hours - to late" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,11,30,0), ends_at: DateTime.new(2015,9,1,12,01,0)})
			appointment.valid?
			expect(appointment.errors[:visit]).to include "doctor doesn't work in clinic in that time"
		end
	end

	context "doctor work in clinic in visit time" do
		it "appointment is created" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,9,1,10,30,0)} )
			appointment.valid?
			expect(appointment.errors[:visit].empty?)
		end
	end


	# test if visit last half hour
	context "inproper visit time" do 
		it "wrong begins time minute" do 
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,1,0), ends_at: DateTime.new(2015,9,1,10,30,0)} )
			appointment.valid?
			expect(appointment.errors[:visit]).to include "visit doesn't last half hour"
		end
		it "wrong ends time minute" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,9,1,10,29,0)} )
			appointment.valid?
			expect(appointment.errors[:visit]).to include "visit doesn't last half hour"
		end
		it "wrong hour" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,30,0), ends_at: DateTime.new(2015,9,1,12,0,0)} )
			appointment.valid?
			expect(appointment.errors[:visit]).to include "visit doesn't last half hour"
		end
	end

	context "proper visit time" do
		it "begins at full hour" do 
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,9,1,10,30,0)} )
			appointment.valid?
			expect(appointment.errors[:visit].empty?)
		end
		it "ends at full hour" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,30,0), ends_at: DateTime.new(2015,9,1,11,00,0)} )
			appointment.valid?
			expect(appointment.errors[:visit].empty?)
		end
	end

	# test if visit begins end ends in proper time frame
	context "visit begins and ends different day" do
		it "different day" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,9,8,10,30,0)} )
			appointment.valid?
			expect(appointment.errors[:visit]).to include "visit should begin and end the same day"
		end

		it "different month" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2015,10,1,10,30,0)} )
			appointment.valid?
			expect(appointment.errors[:visit]).to include "visit should begin and end the same day"
		end

		it "different year" do
			appointment = Appointment.new( {schedule_id: @schedule.id, patient_id: @patient.id,
				begins_at: DateTime.new(2015,9,1,10,0,0), ends_at: DateTime.new(2016,9,1,10,30,0)} )
			appointment.valid?
			expect(appointment.errors[:visit]).to include "visit should begin and end the same day"
		end
	end



end
