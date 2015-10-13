class Users::RegistrationsController < Devise::RegistrationsController
	include ApplicationHelper
	def create
		unless params[:user].has_key?(:role)
			patient = Patient.new(user_params)
			if patient.valid?
				patient.save
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

	def update
		if current_user.is_doctor?
			user_params = update_doctor_params
		elsif current_user.is_patient?
			user_params = update_patient_params
		elsif current_user.is_admin?
			user_params = update_admin_params
		end
		user_params = check_new_password user_params
		if user_params
			user_params.delete_if { |key, value| value.empty? }
			if current_user.update(user_params)
				flash_message :success, I18n.t("devise.registrations.updated")
				redirect_to user_path(current_user[:id])
			else
				current_user.errors.messages.each do |key, errors|
					errors.each do |err|
						flash_message :error, key.to_s + " " + err
					end
				end
				redirect_to edit_user_registration_path
			end
		else
			redirect_to edit_user_registration_path
		end
	end

	private 
	def user_params
		params.require(:user).permit(:email, :password, :password_confirmation, :firstname, :lastname, :address, :pesel, :pwz, :role)
	end

	def update_doctor_params
		params.require(:user).permit(:firstname, :lastname, :address, :pwz, :password, :password_confirmation)
	end

	def update_patient_params
		params.require(:user).permit(:firstname, :lastname, :address, :pesel, :password, :password_confirmation)
	end

	def update_admin_params
		params.require(:user).permit(:firstname, :lastname, :address, :password, :password_confirmation)
	end

	def check_new_password params
		if params[:password].empty? and params[:password_confirmation].empty?
			params.delete(:password)
			params.delete(:password_confirmation)
			return params
		elsif not params[:password].empty? and params[:password_confirmation].empty?
			flash[:error] = "podaj confirm"
			return false
		elsif params[:password].empty? and not params[:password_confirmation].empty?
			flash[:error] = "podaj pass"
			return false
		elsif params[:password] != params[:password_confirmation]
			flash[:error] = "nie pasuja"
			return false
		elsif params[:password] == params[:password_confirmation]
			return params
		end
	end


end
