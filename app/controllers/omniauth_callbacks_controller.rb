# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_oauth(auth)
    if @user.persisted?
      provider = auth.provider.capitalize
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
    else
      session['devise.auth_provider'] = auth.provider
      session['devise.auth_uid'] = auth.uid
      session['devise.auth_name'] = auth.info.name
      session['devise.auth_image'] = auth.info.image
      render 'omniauth/get_email'
    end
  end
  alias twitter facebook

  private

  def auth
    request.env['omniauth.auth'] || OmniAuth::AuthHash.new(
      provider: session['devise.auth_provider'],
      uid: session['devise.auth_uid'],
      info: { email: params[:email],
              name: session['devise.auth_name'],
              image: session['devise.auth_image'] }
    )
  end
end
