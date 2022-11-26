class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  authorize_resource
  impressionist actions: [:show]

  def index
    @users = User.all
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
