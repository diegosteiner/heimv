class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    respond_with @users
  end

  def show
    respond_with @user
  end

  def update
    @user.update(user_params)
    respond_with @user
  end

  def destroy
    @user.destroy
    respond_with @user, location: users_path
  end

  private

  def user_params
    params.require(:user).permit(:role)
  end
end
