class UsersController < ApplicationController
	before_action :authenticate_user!, only: [:show, :index, :update]
	load_and_authorize_resource
	
	def show
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