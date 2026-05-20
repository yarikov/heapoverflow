# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  impressionist actions: [:show]

  rescue_from ActionPolicy::Unauthorized do
    redirect_to action: :show
  end

  def index
    authorize! User.new
    @pagy, @users = pagy(:offset, User.with_attached_avatar.order(full_name: 'asc'), limit: 32)
  end

  def show
    authorize! @user
  end

  def edit
    authorize! @user
  end

  def update
    authorize! @user
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
