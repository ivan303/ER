class Schedule < ActiveRecord::Base


	belongs_to :employment
	has_many :appointments

	validates :begins_at, presence: true
	validates :ends_at, presence: true
	validates :weekday, presence: true
	validates :employment_id, presence: true

	validates_format_of :begins_at, with:  /\A\d{4}\-\d{2}\-\d{2} \d{2}\:(00|30)\:00.*\Z/
	validates_format_of :ends_at, with:  /\A\d{4}\-\d{2}\-\d{2} \d{2}\:(00|30)\:00.*\Z/
	validates :weekday, inclusion: { in: %w(Mon Tue Wed Thu Fri Sat Sun) }

	validate :ends_at_proceeds_begins_at
	validate :doctor_working_hours_not_overlap
	validate :at_most_two_shifts_in_one_clinic

	def comparable_begins_at_format
		self.begins_at.strftime('%H%M').sub(/^0{,3}/, "").to_i unless self.begins_at.nil?
	end

	def comparable_ends_at_format
		self.ends_at.strftime('%H%M').sub(/^0{,3}/, "").to_i unless self.ends_at.nil?
	end

	def readable_begins_at_format
		self.begins_at.strftime('%H:%M') unless self.begins_at.nil?
	end

	def readable_ends_at_format
		self.ends_at.strftime('%H:%M') unless self.ends_at.nil?
	end

	def ends_at_proceeds_begins_at
		unless comparable_ends_at_format.nil? or comparable_begins_at_format.nil?
			if comparable_ends_at_format <= comparable_begins_at_format
				errors.add(:ends_at, "must proceeds begins_at")
			end
		end
	end

	# if we allow a doctor to work in one clinic in two periods one day
	def at_most_two_shifts_in_one_clinic
		if Schedule.where(employment_id: self.employment_id, weekday: self.weekday).count >= 2
			errors.add("shifts", "at most two shift per day")
		end
	end

	def doctor_working_hours_not_overlap
		unless Schedule.all.empty?
			if (schedules = Schedule.joins(:employment).where(employments: { doctor_id: self.employment.doctor_id })).exists?
				schedules.each do |schedule|
					unless self.comparable_begins_at_format > schedule.comparable_ends_at_format or self.comparable_ends_at_format < schedule.comparable_begins_at_format
						errors.add("shifts", "can't overlap")
					end
				end
			end
		end
	end

end