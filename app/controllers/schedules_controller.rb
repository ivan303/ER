class SchedulesController < ApplicationController
	include ApplicationHelper
	before_action :authenticate_user!, only: [:show, :create, :edit, :index]
	protect_from_forgery except: :destroy
	respond_to :json

	def show

	end

	def create
		schedule_par = schedule_params
		zone = ActiveSupport::TimeZone.new("Warsaw")
		schedule_par[:begins_at] = schedule_par[:begins_at].in_time_zone(zone)
		schedule_par[:ends_at] = schedule_par[:ends_at].in_time_zone(zone)
		schedule = Schedule.new(schedule_par)

		if schedule.save
			redirect_to schedules_path
		else
			schedule.errors.messages.each do |key, errors|
				errors.each do |err|
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
