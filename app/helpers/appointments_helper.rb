module AppointmentsHelper

	def find_closest_search_time from
		from_min = from.strftime("%M").to_i
		from_hour = from.strftime("%H").to_i
		closest_time = from
		if from_min >= 0 && from_min <= 29
			closest_time = closest_time.change(min: 30)
		elsif from_min >= 30 && from_min <= 59
			closest_time = closest_time.change(hour: from_hour + 1)
		end
		return closest_time
	end

	def prepare_first_free_visit_in_clinic_params clinic_id
		employments = Employment.where(clinic_id: clinic_id)
		schedules = []
		employments.each do |employment|
			schedules << Schedule.where(employment_id: employment.id)
		end
		schedules.flatten!

		schedule_appointments = {}
		schedules.each do |schedule|
			schedule_appointments[schedule] = Appointment.where(schedule: schedule)
		end
		schedules_in_day = {}
		%w(Mon Tue Wed Thu Fri Sat Sun).each do |day|
			schedules_in_day[day] = []
			schedules.each do |schedule|
				if schedule.weekday == day
					schedules_in_day[day] << schedule
				end
			end
		end

		zone = ActiveSupport::TimeZone.new("Warsaw")

		closest_time = find_closest_search_time(DateTime.now)
		appointment_hash = {}

		visit_found = false
		while !visit_found
			weekday = closest_time.strftime("%a")
			schedules_in_day[weekday].each do |schedule|
				if comparable_time_format(schedule.ends_at.in_time_zone(zone)) > comparable_time_format(closest_time) && 
					comparable_time_format(schedule.begins_at.in_time_zone(zone)) <= comparable_time_format(closest_time)
					unless schedule_appointments[schedule].exists?(begins_at: closest_time)
						appointment_hash[:schedule_id] = schedule.id
						appointment_hash[:begins_at] = closest_time.utc
						appointment_hash[:ends_at] = closest_time.utc + 30.minutes
						visit_found = true
						break
					end
				end
			end
			unless visit_found
				closest_time += 30.minutes
			end
		end

		return appointment_hash
	end

	def prepare_first_free_visit_at_doctor_params doctor_id
		employments = Employment.where(doctor_id: doctor_id)
		schedules = []
		employments.each do |employment|
			schedules << Schedule.where(employment_id: employment.id)
		end
		schedules.flatten!

		schedule_appointments = {}
		schedules.each do |schedule|
			schedule_appointments[schedule] = Appointment.where(schedule: schedule)
		end

		schedules_in_day = {}
		%w(Mon Tue Wed Thu Fri Sat Sun).each do |day|
			schedules_in_day[day] = []
			schedules.each do |schedule|
				if schedule.weekday == day
					schedules_in_day[day] << schedule
				end
			end
		end

		zone = ActiveSupport::TimeZone.new("Warsaw")

		closest_time = find_closest_search_time(DateTime.now)
		appointment_hash = {}

		visit_found = false
		while !visit_found
			weekday = closest_time.strftime("%a")
			schedules_in_day[weekday].each do |schedule|
				if comparable_time_format(schedule.ends_at.in_time_zone(zone)) > comparable_time_format(closest_time) && 
					comparable_time_format(schedule.begins_at.in_time_zone(zone)) <= comparable_time_format(closest_time)
					unless schedule_appointments[schedule].exists?(begins_at: closest_time)
						appointment_hash[:schedule_id] = schedule.id
						appointment_hash[:begins_at] = closest_time.utc
						appointment_hash[:ends_at] = closest_time.utc + 30.minutes
						visit_found = true
						break
					end
				end
			end
			unless visit_found
				closest_time += 30.minutes
			end
		end

		return appointment_hash
	end



	def comparable_time_format time_to_format
		time_to_format.strftime('%H%M').sub(/^0{,3}/, "").to_i unless time_to_format.nil?
	end

end
