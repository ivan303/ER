class Patient < User
	validates :pesel, presence: true
	validates :pwz, absence: true

	validates_format_of :pesel, with: /\A[0-9]{11}\Z/
end