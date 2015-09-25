class SchedulesController < ApplicationController
	include ApplicationHelper
	before_action :authenticate_user!, only: [:show, :create, :edit, :index]
	protect_from_forgery except: :destroy
	# protect_from_forgery with: :null_session
	# TODO check above line
	respond_to :json

	def show

	end

	def create
		schedule = Schedule.new(schedule_params)
		if schedule.save
			redirect_to schedules_path
		else
			byebug
			schedule.errors.messages.each do |key, errors|
				errors.each do |err|
					byebug
					flash_message :error, I18n.t("schedules.errors.#{key}.#{err}")
				end
			end
			redirect_to schedules_path
		end
	end

	def edit
	end

	def index
		if current_user.is_doctor?
			@doctor = current_user
			@employments = Employment.where(doctor_id: @doctor.id)
			@clinics = Clinic.joins(employments: :doctor).where("employments.doctor_id = ?", @doctor.id)
			@new_schedule = Schedule.new
			@schedules = []
			@employments.each do |employment|
				@schedules << Schedule.doctor_clinic_schedule(@doctor, employment.clinic)
			end
			gon.schedules = @schedules.flatten!.as_json
		end
	end

	def destroy
		schedule = Schedule.find(params[:id])
		if schedule
			if schedule.destroy
				head 204
			else
				render json: { errors: schedule.errors }, status: 422
			end
		else
			render json: { errors: 'Not found' }, status: 404
		end
	end

	private

		def schedule_params
			params.require(:schedule).permit(:employment_id, :weekday, :begins_at, :ends_at)
		end
end
