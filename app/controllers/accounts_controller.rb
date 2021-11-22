# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_user

  def edit
    authorize! :set_password, @user
  end

  def update
    authorize! :set_password, @user
    @user.update(user_params)
    respond_with @user, location: organisation_path
  end

  private

  def set_user
    @user = current_user
    raise CanCan::AccessDenied if @user.blank? || (current_organisation && @user.organisation != current_organisation)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
