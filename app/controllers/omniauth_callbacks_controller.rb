# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = Oauth::FindOrCreateUser.call(auth)
    if @user.persisted?
      sign_in_oauth_user
    else
      store_oauth_auth_data
      render 'omniauth/get_email'
    end
  end
  alias twitter facebook

  private

  def sign_in_oauth_user
    provider = auth.provider.capitalize
    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
  end

  def store_oauth_auth_data
    auth_data = {
      'devise.auth_provider' => auth.provider,
      'devise.auth_uid' => auth.uid,
      'devise.auth_name' => auth.info.name,
      'devise.auth_image' => auth.info.image
    }
    session.merge!(auth_data)
  end

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
