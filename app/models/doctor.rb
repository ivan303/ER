class Doctor < User
	has_many :employments, dependent: :destroy

	scope :employed_in_clinic, -> (clinic) { joins(:employments).where("employments.clinic_id = ?", clinic.id) }

	
	validates :pesel, absence: true
	validates :pwz, presence: true

	validates_format_of :pwz, with: /\A[0-9]{7}\Z/
end