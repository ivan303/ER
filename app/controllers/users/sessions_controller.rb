class Users::SessionsController < Devise::SessionsController
	include ApplicationHelper
	def create
		user = User.find_by(email: params[:user][:email])
		if user
			if user.valid_password?(params[:user][:password])
				if user.role == 'Patient'
					if user.approved?
						sign_in user
						flash[:success] = I18n.t("devise.sessions.signed_in")
						redirect_to user_path(current_user)
					else
						flash[:alert] = I18n.t("devise.failure.not_approved")
						redirect_to new_user_session_path
					end
				else
					sign_in user
					flash[:success] = I18n.t("devise.sessions.signed_in")
					redirect_to user_path(current_user)
				end
			else
				flash[:error] = I18n.t("devise.failure.invalid")
				redirect_to new_user_session_path
			end
		else
			flash[:error] = I18n.t("devise.failure.not_found_in_database")
			redirect_to new_user_session_path
		end
	end

	def destroy
		sign_out current_user
		redirect_to new_user_session_path
	end

	private 
		def user_params
			params.require(:user).permit(:email, :password)
		end
end