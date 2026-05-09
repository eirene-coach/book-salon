class Users::OmniauthCallbacksController < Devise::OmniAuthCallbacksController
  def google_oauth2
    handle_auth("Google")
  end

  def kakao
    handle_auth("카카오")
  end

  private

  def handle_auth(provider_name)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    else
      session["devise.omniauth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: "로그인에 실패했습니다."
    end
  end
end
