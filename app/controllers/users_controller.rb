class UsersController < ApplicationController
	before_action :authenticate_user!, only: [:show, :index, :update]
	load_and_authorize_resource
	
	def show
		Appointment.remove_unconfirmed_appointments
		if current_user.is_admin?
			@appointments = Appointment.all.order(:begins_at).reverse
		elsif current_user.is_doctor?
			employments = Employment.where(doctor_id: current_user.id)
			schedules = []
			employments.each do |employment|
				schedules << Schedule.where(employment_id: employment.id)
			end
			schedules.flatten!
			@appointments = []
			schedules.each do |schedule|
				@appointments << Appointment.where(schedule_id: schedule.id).where.not(confirmed_at: nil)
			end
			@appointments.flatten!
		elsif current_user.is_patient?
			@appointments = Appointment.where(patient_id: current_user.id)
		end
	end

	def index
		@patients = Patient.all
	end

	def update
		user = User.find(params[:id])
		user.update_attributes(user_params)
		redirect_to users_path
	end

	private	
		def user_params
			params.require(:user).permit(:approved)
		end
end