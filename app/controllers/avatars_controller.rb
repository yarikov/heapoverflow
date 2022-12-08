# frozen_string_literal: true

class AvatarsController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  def update
    if current_user.avatar.attach(params[:user][:avatar])
      render :update
    else
      flash.now[:error] = current_user.errors.full_messages.first
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.avatar.destroy
  end
end
