require 'rails_helper'

describe Schedule do

	it { should validate_presence_of(:weekday) }
	it { should validate_presence_of(:begins_at) }
	it { should validate_presence_of(:ends_at) }
	it { should validate_presence_of(:employment_id)}
	it { should allow_value('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun').for(:weekday) }
	it { should allow_value('2015-08-30 14:00:00', '2015-08-31 15:30:00').for(:begins_at) }
	it { should allow_value('2015-08-30 20:00:00', '2015-08-31 15:30:00').for(:ends_at) }

	it "ends_at proceeds_begins_at" do
		doctor = FactoryGirl.create(:doctor)
		clinic = FactoryGirl.create(:clinic)
		employment = FactoryGirl.create(:employment, doctor_id: doctor.id, clinic_id: clinic.id)
		schedule = FactoryGirl.build(:schedule, employment_id: employment.id, 
			begins_at: DateTime.new(2015,8,30,18,0,0), ends_at: DateTime.new(2015,8,30,17,0,0))
		schedule.valid?
		expect(schedule.errors[:ends_at]).to include 'preceds_begins_at'
	end
	
	context "custom validations" do
		before(:each) do
			@doctor = FactoryGirl.create(:doctor)
			@clinic = FactoryGirl.create(:clinic)
			@employment = FactoryGirl.create(:employment, doctor_id: @doctor.id, clinic_id: @clinic.id)
			@schedule = FactoryGirl.create(:schedule, employment_id: @employment.id)
		end


		it "should not allow more than two shifs in one clinic for doctor per day" do
			schedule2 = FactoryGirl.create(:schedule, employment_id: @employment.id, weekday: @schedule.weekday, 
				begins_at: DateTime.new(2015,8,30,17,0,0), ends_at: DateTime.new(2015,8,30,18,0,0))
			schedule3 = FactoryGirl.build(:schedule, employment_id: @employment.id, weekday: @schedule.weekday)
			schedule3.valid?
			expect(schedule3.errors[:shifts]).to include 'more_than_two'
		end

		context "shifts overlap" do
			context "in the same clinic" do
				it "the same time" do
					schedule2 = FactoryGirl.build(:schedule, employment_id: @employment.id, weekday: @schedule.weekday)
					schedule2.valid?
					expect(schedule2.errors[:shifts]).to include "overlap"
				end

				it "second begins before first ends" do
					schedule2 = FactoryGirl.build(:schedule, employment_id: @employment.id, weekday: @schedule.weekday,
						begins_at: DateTime.new(2015,8,30,16,0,0), ends_at: DateTime.new(2015,8,30,18,0,0))
					schedule2.valid?
					expect(schedule2.errors[:shifts]).to include "overlap"
				end

				it "second ends after first begins" do
					schedule2 = FactoryGirl.build(:schedule, employment_id: @employment.id, weekday: @schedule.weekday,
						begins_at: DateTime.new(2015,8,30,8,0,0), ends_at: DateTime.new(2015,8,30,10,0,0))
					schedule2.valid?
					expect(schedule2.errors[:shifts]).to include "overlap"
				end
			end

			context "in other clinic" do
				before(:each) do
					@clinic1 = FactoryGirl.create(:clinic)
					@employment1 = FactoryGirl.create(:employment, doctor_id: @doctor.id, clinic_id: @clinic1.id)
				end

				it "the same time" do
					schedule2 = FactoryGirl.build(:schedule, employment_id: @employment1.id, weekday: @schedule.weekday)
					schedule2.valid?
					expect(schedule2.errors[:shifts]).to include "overlap"
				end

				it "second begins before first ends" do
					schedule2 = FactoryGirl.build(:schedule, employment_id: @employment1.id, weekday: @schedule.weekday,
						begins_at: DateTime.new(2015,8,30,16,0,0), ends_at: DateTime.new(2015,8,30,18,0,0))
					schedule2.valid?
					expect(schedule2.errors[:shifts]).to include "overlap"
				end

				it "second ends after first begins" do
					schedule2 = FactoryGirl.build(:schedule, employment_id: @employment1.id, weekday: @schedule.weekday,
						begins_at: DateTime.new(2015,8,30,8,0,0), ends_at: DateTime.new(2015,8,30,10,0,0))
					schedule2.valid?
					expect(schedule2.errors[:shifts]).to include "overlap"
				end
			end
		end
	end
end
