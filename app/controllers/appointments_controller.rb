class AppointmentsController < ApplicationController
	before_action :authenticate_user!

	include ApplicationHelper
	include AppointmentsHelper
	respond_to :json

	def index
		@employments = Employment.all
		@clinics = Clinic.all
		@doctors = Doctor.all

		gon.employments = @employments.as_json
		gon.clinics = @clinics.as_json
		gon.doctors = @doctors.as_json
		gon.current_user_id = current_user.id

		@doctors_in_clinic = Doctor.employed_in_clinic(@clinics.first).order(lastname: :desc, firstname: :desc)
		@new_appointment = Appointment.new
		
		@schedules = []
		@appointments = []

		employment = Employment.find_by(doctor_id: @doctors_in_clinic.first.id, clinic_id: @clinics.first.id)
		if employment
			@schedules << Schedule.where(employment_id: employment.id)
			gon.schedules = @schedules.flatten!.as_json

			@schedules.each do |schedule|
				@appointments << Appointment.where(schedule_id: schedule.id)
			end
			gon.appointments = @appointments.flatten!.as_json
		end
	end

	def destroy
		appointment = Appointment.find(params[:id])
		if appointment.can_delete?
			appointment.destroy
			flash_message :success, I18n.t("appointments.destroy.success")
			redirect_to user_path(current_user.id)
		else
			flash_message :error, I18n.t("appointments.destroy.error")
			redirect_to user_path(current_user.id)
		end
	end

	def create
		Appointment.remove_unconfirmed_appointments
		appointment_hash = prepare_appointment_params
		unless appointment_hash.has_key?(:errors)
			appointment = Appointment.new(appointment_hash)
			if appointment.save
				flash_message :success, I18n.t("appointments.create.success")
				redirect_to appointments_path
			else
				appointment.errors.messages.each do |key, errors|
					errors.each do |err|
						flash_message :error, I18n.t("appointments.errors.#{key}.#{err}")
					end
				end
				redirect_to appointments_path
			end
		else
			appointment_hash[:errors].each do |key, err|
				flash_message :error, I18n.t("appointments.errors.#{key}.#{err}")
			end
			redirect_to appointments_path
		end
	end

	def update_calendar
		doctor_id = params[:doctor_id]
		clinic_id = params[:clinic_id]
		doctor = Doctor.find(doctor_id)
		clinic = Clinic.find(clinic_id)

		if doctor && clinic
			schedules = Schedule.doctor_clinic_schedule(doctor, clinic) || []
			appointments = []
			schedules.each do |schedule|
				appointments << Appointment.where(schedule_id: schedule.id)
			end
			appointments.flatten!
			response = [schedules, appointments]
			respond_with response
		else
			respond_with [[],[]]
		end
	end

	def create_appointment_in_clinic
		appointment_hash = prepare_first_free_visit_in_clinic_params(params[:appointment][:clinic_id])
		appointment_hash[:patient_id] = params[:appointment][:patient_id]
		appointment = Appointment.new(appointment_hash)
		if appointment.save
			flash = prepare_flash_message(appointment_hash)
			render json: { flash: flash }, status: 201
		else
			render json: { flash: "error" }, status: 422
		end
	end

	def create_appointment_at_doctor
		appointment_hash = prepare_first_free_visit_at_doctor_params(params[:appointment][:doctor_id])

		appointment_hash[:patient_id] = params[:appointment][:patient_id]
		appointment = Appointment.new(appointment_hash)
		if appointment.save
			flash = prepare_flash_message(appointment_hash)
			render json: { flash: flash }, status: 201
		else
			respond_with json: { flash: "error" }, status: 422
		end
	end

	def confirm
		appointment = Appointment.find(params[:id])
		if appointment.can_confirm?
			appointment.update_attribute(:confirmed_at, DateTime.now)
		else
			flash_message :error, I18n.t("appointments.confirm.error")
		end
		redirect_to user_path(current_user.id)
	end

	private

		def prepare_appointment_params
			zone = ActiveSupport::TimeZone.new("Warsaw")
			doctor_id = params[:appointment][:doctor_id]
			clinic_id = params[:appointment][:clinic_id]
			patient_id = params[:appointment][:patient_id]
			year = params[:appointment]["date(1i)"]
			month = params[:appointment]["date(2i)"]
			day = params[:appointment]["date(3i)"]
			weekday = DateTime.new(year.to_i, month.to_i, day.to_i).strftime('%a')
			start_time = DateTime.strptime(params[:appointment][:begins_at], '%Y-%m-%d %H:%M:%S')#.in_time_zone(zone)
			end_time = start_time + 30.minutes

			start_hour = start_time.strftime('%H')
			start_minute = start_time.strftime('%M')
			end_hour = end_time.strftime('%H')
			end_minute = end_time.strftime('%M')

			check_time = DateTime.new(year.to_i, month.to_i, day.to_i, start_hour.to_i, start_minute.to_i, 0)
			result_hash = {}
			unless check_time < DateTime.now
				correct_schedule = nil
				employment = Employment.find_by(doctor_id: doctor_id, clinic_id: clinic_id)
				schedules = Schedule.where(employment_id: employment.id, weekday: weekday)
				unless schedules.empty?
					schedules.each do |schedule|
						if comparable_time_format(schedule.begins_at.in_time_zone(zone)) <= comparable_time_format(start_time) && 
							comparable_time_format(schedule.ends_at.in_time_zone(zone)) >= comparable_time_format(start_time)
							correct_schedule = schedule
						end
					end
					if correct_schedule
						result_hash[:begins_at] = DateTime.new(year.to_i, month.to_i, day.to_i, start_hour.to_i, start_minute.to_i, 0, '+2').utc()
						result_hash[:ends_at] = DateTime.new(year.to_i, month.to_i, day.to_i, end_hour.to_i, end_minute.to_i, 0, '+2').utc()
						result_hash[:patient_id] = patient_id.to_i
						result_hash[:schedule_id] = correct_schedule.id
						return result_hash
					else
						result_hash[:errors] ||= {}
						result_hash[:errors][:visit] = 'not_work_that_time'
						return result_hash
					end
				else
					result_hash[:errors] ||= {}
					result_hash[:errors][:visit] = 'not_work_that_day'
					return result_hash
				end
			else
				result_hash[:errors] ||= {}
				result_hash[:errors][:visit] = 'time_in_the_past'
				return result_hash
			end

		end

		def prepare_flash_message appointment_hash
			zone = ActiveSupport::TimeZone.new("Warsaw")
			flash = "Appointment successfully created. Clinic: " + Schedule.find(appointment_hash[:schedule_id]).employment.clinic.name + "; "
			flash += "doctor: " + Schedule.find(appointment_hash[:schedule_id]).employment.doctor.firstname + " " 
			flash += Schedule.find(appointment_hash[:schedule_id]).employment.doctor.lastname + "; "
			flash += "date: " + appointment_hash[:begins_at].in_time_zone(zone).strftime("%Y-%m-%d %H:%M:%S. ")
			flash += "Please go to your profile page and confirm it in 10 minutes"
		end
		
end
