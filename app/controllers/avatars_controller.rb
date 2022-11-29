class AvatarsController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  def update
    current_user.avatar.attach(params[:user][:avatar])
    render :update
  end
end
