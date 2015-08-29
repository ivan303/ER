class Employment < ActiveRecord::Base
	belongs_to :doctor
	belongs_to :clinic

	validates :doctor, presence: true, uniqueness: { scope: :clinic }
	validates :clinic, presence: true
end
