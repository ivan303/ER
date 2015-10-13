class EmploymentsController < ApplicationController
	include ApplicationHelper
	def index
		@employments = Employment.all
		@doctors = Doctor.all
		@clinics = Clinic.all
		@new_employment = Employment.new

		@doctors_in_clinic = @doctors - Doctor.employed_in_clinic(@clinics.first)
		
		gon.employments = @employments
		gon.doctors = @doctors
		gon.clinics = @clinics

	end

	def destroy
		employment = Employment.find(params[:id])
		if employment.destroy
			flash_message :success, I18n.t("employments.destroy.success")
		else
			flash_message :error, I18n.t("employments.destroy.error")
		end
		redirect_to employments_path
	end

	def create
		employment = Employment.new(employment_params)
		if employment.save
			flash_message :success, I18n.t("employments.create.success")
			redirect_to employments_path
		else
			flash_message :error, I18n.t("employments.create.error")
			redirect_to employments_path
		end
	end

	private
		def employment_params
			params.require(:employment).permit(:doctor_id, :clinic_id)
		end

end
