class DoctorsController < ApplicationController
	include ApplicationHelper
	before_action :authenticate_user!, only: [:index, :update, :destroy, :create]
	load_and_authorize_resource

	def index
		@doctors = Doctor.all.order(:created_at).reverse
		@new_doctor = Doctor.new
	end

	def update
		doctor = Doctor.find(params[:id])
		doctor.update_attributes(doctor_params)
		redirect_to doctors_path
	end

	def destroy
		doctor = Doctor.find(params[:id])
		if doctor.destroy
			flash_message :success,  I18n.t("doctors.destroy.success")
			redirect_to doctors_path
		else
			flash_message :error, I18n.t("doctors.destroy.error")
		end
	end

	def create
		doctor = Doctor.new(doctor_params)
		doctor.approved = true
		if doctor.save
			flash_message :success, I18n.t("doctors.create.success")
			redirect_to doctors_path
		else
			flash_message :error, I18n.t("doctors.create.error")
			redirect_to doctors_path
		end
	end


	private

		def doctor_params
			params.require(:doctor).permit(:approved, :firstname, :lastname, :pwz, :email, :password, :address)
		end

end
