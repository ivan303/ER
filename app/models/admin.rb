class Admin < User
	validates :pesel, absence: true
	validates :pwz, absence: true
end