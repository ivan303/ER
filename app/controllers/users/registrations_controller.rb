class Users::RegistrationsController < Devise::RegistrationsController
	def create
		byebug
		unless params[:user].has_key?(:role)
			patient = Patient.new(user_params)
			if patient.valid?
				patient.save
				byebug
				flash[:success] = I18n.t("devise.registrations.user.signed_up_but_not_approved")
				redirect_to new_user_registration_path
			else
				# flash[:error] = 
				redirect_to new_user_registration_path
			end
		else
			# flash
			redirect_to new_user_registration_path
		end
	end

	private 
	def user_params
		params.require(:user).permit(:email, :password, :password_confirmation, :firstname, :lastname, :address, :pesel, :pwz, :role)
	end
end
