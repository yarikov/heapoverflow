# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  authorize_resource
  impressionist actions: [:show]

  rescue_from CanCan::AccessDenied do
    redirect_to action: :show
  end

  def index
    @pagy, @users = pagy(User.with_attached_avatar.order(full_name: 'asc'), items: 32)
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user)
          .permit(:full_name, :avatar, :location, :description, :website, :github, :twitter)
  end
end
