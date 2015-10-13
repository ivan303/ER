puts 'Creating doctors'
doctors = []
5.times do 
	doctors << FactoryGirl.create(:doctor)
end

clinics = []
2.times do
	clinics << FactoryGirl.create(:clinic)
end

employments = []
employments << Employment.create(clinic: clinics[0], doctor: doctors[0])
employments << Employment.create(clinic: clinics[0], doctor: doctors[1])
employments << Employment.create(clinic: clinics[0], doctor: doctors[2])
employments << Employment.create(clinic: clinics[1], doctor: doctors[2])
employments << Employment.create(clinic: clinics[1], doctor: doctors[3])
employments << Employment.create(clinic: clinics[1], doctor: doctors[4])

schedules = []
schedules << Schedule.create(employment_id: employments[1].id, weekday: 'Mon',
			begins_at: DateTime.new(2015,8,30,9,0,0), ends_at: DateTime.new(2015,8,30,15,0,0))
schedules << Schedule.create(employment_id: employments[1].id, weekday: 'Tue',
			begins_at: DateTime.new(2015,8,31,8,0,0), ends_at: DateTime.new(2015,8,31,12,0,0))
schedules << Schedule.create(employment_id: employments[1].id, weekday: 'Tue',
			begins_at: DateTime.new(2015,8,31,15,0,0), ends_at: DateTime.new(2015,8,31,19,0,0))

schedules << Schedule.create(employment_id: employments[2].id, weekday: 'Mon',
			begins_at: DateTime.new(2015,8,30,9,0,0), ends_at: DateTime.new(2015,8,30,15,0,0))
schedules << Schedule.create(employment_id: employments[2].id, weekday: 'Tue',
			begins_at: DateTime.new(2015,8,31,9,0,0), ends_at: DateTime.new(2015,8,31,15,0,0))
schedules << Schedule.create(employment_id: employments[3].id, weekday: 'Mon',
			begins_at: DateTime.new(2015,8,30,17,0,0), ends_at: DateTime.new(2015,8,30,19,0,0))
schedules << Schedule.create(employment_id: employments[3].id, weekday: 'Wed',
			begins_at: DateTime.new(2015,9,1,9,0,0), ends_at: DateTime.new(2015,9,1,15,0,0))