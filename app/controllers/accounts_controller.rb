# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_user
  authorize_resource :user

  def edit; end

  def update
    @user.update(user_params)
    respond_with @user, location: edit_account_path
  end

  private

  def set_user
    @user = current_user
    raise CanCan::AccessDenied if @user.blank?
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
