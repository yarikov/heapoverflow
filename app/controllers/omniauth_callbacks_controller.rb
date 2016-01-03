class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_oauth(auth)
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: auth.provider.capitalize) if is_navigational_format?
    else
      session['devise.auth_provider'] = auth.provider
      session['devise.auth_uid'] = auth.uid
      render 'omniauth/get_email'
    end
  end
  alias_method :twitter, :facebook

  private

  def auth
    request.env['omniauth.auth'] || OmniAuth::AuthHash.new(
      provider: session['devise.auth_provider'],
      uid: session['devise.auth_uid'],
      info: { email: params[:email] }
    )
  end
end
