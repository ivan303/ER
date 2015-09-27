class AppointmentsController < ApplicationController
	respond_to :json

	def index
		@employments = Employment.all
		@clinics = Clinic.all
		@doctors = Doctor.all

		gon.employments = @employments.as_json
		gon.clinics = @clinics.as_json
		gon.doctors = @doctors.as_json

		@doctors_in_clinic = Doctor.employed_in_clinic(@clinics.first)
		@new_appointment = Appointment.new
		
		# byebug
		@schedules = []
		employment = Employment.find_by(doctor_id: @doctors_in_clinic.first.id, clinic_id: @clinics.first.id)
		@schedules << Schedule.where(employment_id: employment.id)
		gon.schedules = @schedules.flatten!.as_json
	end

	def update_calendar
		doctor_id = params[:doctor_id]
		clinic_id = params[:clinic_id]
		doctor = Doctor.find(doctor_id)
		clinic = Clinic.find(clinic_id)

		schedules = Schedule.doctor_clinic_schedule(doctor, clinic)
		respond_with schedules
	end
end
