class ClinicsController < ApplicationController
	include ApplicationHelper
	before_action :authenticate_user!, only: [:index, :destroy]
	load_and_authorize_resource

	def index
		@clinics = Clinic.all.order(:name)
	end

	def destroy
		byebug
		clinic = Clinic.find(params[:id])
		if clinic # DELETE
			flash_message :success,  I18n.t("clinics.destroy.success")
			redirect_to clinics_path
		else
			flash_message :error, "nie udało sie" #TODO
		end
	end
end
