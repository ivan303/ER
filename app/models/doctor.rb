class Doctor < User
	has_many :employments
	
	validates :pesel, absence: true
	validates :pwz, presence: true

	validates_format_of :pwz, with: /\A[0-9]{7}\Z/
end