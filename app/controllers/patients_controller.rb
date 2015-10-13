class PatientsController < ApplicationController
	include ApplicationHelper
	before_action :authenticate_user!, only: [:index, :update, :destroy]
	load_and_authorize_resource

	def index
		@patients = Patient.all.order(:created_at).reverse
	end

	def update
		patient = Patient.find(params[:id])
		patient.update_attributes(patient_params)
		redirect_to patients_path
	end

	def destroy
		patient = Patient.find(params[:id])
		if patient.delete
			flash_message :success,  I18n.t("patients.destroy.success")
			redirect_to patients_path
		else
			flash_message :error, I18n.t("patients.destroy.error")
		end
	end

	private

		def patient_params
			params.require(:patient).permit(:approved)
		end
end
