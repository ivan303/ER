class Employment < ActiveRecord::Base
	belongs_to :doctor
	belongs_to :clinic

	has_many :schedules, dependent: :destroy

	validates :doctor, presence: true, uniqueness: { scope: :clinic }
	validates :clinic, presence: true
end
