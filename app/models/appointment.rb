class Appointment < ActiveRecord::Base

	belongs_to :schedule
	belongs_to :patient

	attr_accessor :doctor_id
	attr_accessor :clinic_id
	attr_accessor :weekday
	attr_accessor :date

	validates :schedule_id, presence: true
	validates :patient_id, presence: true
	validates :begins_at, presence: true
	validates :ends_at, presence: true

	validates_format_of :begins_at, with:  /\A\d{4}\-\d{2}\-\d{2} \d{2}\:(00|30)\:00.*\Z/
	validates_format_of :ends_at, with:  /\A\d{4}\-\d{2}\-\d{2} \d{2}\:(00|30)\:00.*\Z/

	def comparable_begins_at_format
		self.begins_at.strftime('%H%M').sub(/^0{,3}/, "").to_i unless self.begins_at.nil?
	end

	def comparable_ends_at_format
		self.ends_at.strftime('%H%M').sub(/^0{,3}/, "").to_i unless self.ends_at.nil?
	end

	def self.remove_unconfirmed_appointments
		now = DateTime.now
		appointments = Appointment.all
		appointments.each do |appointment|
			unless appointment[:confirmed_at]
				if appointment.created_at + 10.minutes < now.utc()
					appointment.destroy
				end
			end
		end
	end

	validate :doctor_works_in_clinic_in_visit_time
	validate :visit_begins_and_ends_the_same_day
	validate :visit_last_half_hour
	validate :doctor_is_free_in_visit_time

	def schedule_id_exists
		if Schedule.find(self.schedule_id).nil?
			errors.add(:schedule_id, "doesn't exists")
			false
		end
	end

	def doctor_works_in_clinic_in_visit_time
		if self.schedule_id and Schedule.find(self.schedule_id)
			schedule = Schedule.find(schedule_id)
			unless begins_at.strftime('%a') == schedule.weekday
				errors.add("visit", "not_work_that_day")
				return false
			end

			unless self.comparable_begins_at_format >= schedule.comparable_begins_at_format and
				self.comparable_ends_at_format <= schedule.comparable_ends_at_format
				errors.add("visit", "not_work_that_time")
				return false
			end
		end
	end

	def doctor_is_free_in_visit_time
		if self.begins_at and self.ends_at and self.schedule_id
			if Appointment.where(schedule_id: self.schedule_id, begins_at: self.begins_at, ends_at: self.ends_at).exists?
				errors.add("visit", "another_visit")
				return false
			end
		end
	end

	def visit_last_half_hour
		if self.begins_at and self.ends_at
			if self.begins_at.strftime('%H') == self.ends_at.strftime('%H')
				unless self.begins_at.strftime('%M') == '00' and self.ends_at.strftime('%M') == '30'
					errors.add("visit", "not_half_hour")
					return false
				end
			elsif self.begins_at.strftime('%H').to_i + 1 == self.ends_at.strftime('%H').to_i
				unless self.begins_at.strftime('%M') == '30' and self.ends_at.strftime('%M') == '00'
					errors.add("visit", "not_half_hour")
					return false
				end
			else
				errors.add("visit", "not_half_hour")
				return false
			end
		end
	end

	def visit_begins_and_ends_the_same_day
		if self.begins_at and self.ends_at
			unless self.begins_at.strftime('%d%m%Y') == self.ends_at.strftime('%d%m%Y')
				errors.add("visit", "begins_ends_one_day")
				return false
			end
		end
	end

	def can_delete?
		if self.begins_at > DateTime.now.utc()
			true
		else
			false
		end
	end

	def can_confirm?
		if self.created_at + 10.minutes > DateTime.now.utc()
			true
		else
			false
		end
	end
end
