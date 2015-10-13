class ClinicsController < ApplicationController
	include ApplicationHelper
	before_action :authenticate_user!, only: [:index, :destroy]
	load_and_authorize_resource

	def index
		@clinics = Clinic.all.order(:name)
		@new_clinic = Clinic.new
	end

	def destroy
		clinic = Clinic.find(params[:id])
		if clinic.destroy
			flash_message :success,  I18n.t("clinics.destroy.success")
			redirect_to clinics_path
		else
			flash_message :error, I18n.t("clinics.destroy.error")
		end
	end

	def create
		clinic = Clinic.new(clinic_params)
		if clinic.save
			flash_message :success, I18n.t("clinics.create.success")
			redirect_to clinics_path
		else
			flash_message :error, I18n.t("clinics.create.error")
			redirect_to clinics_path
		end
	end

	private
		def clinic_params
			params.require(:clinic).permit(:name)
		end


end
