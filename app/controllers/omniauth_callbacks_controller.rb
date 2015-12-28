class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_oauth(auth)
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: auth.provider.capitalize) if is_navigational_format?
    else
      render 'omniauth/get_email', locals: { auth: request.env['omniauth.auth'] }
    end
  end
  alias_method :twitter, :facebook

  private

  def auth
    request.env['omniauth.auth'] || OmniAuth::AuthHash.new(params[:auth])
  end
end
