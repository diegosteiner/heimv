# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_user

  def edit
    authorize! :set_password, @user
  end

  def update
    authorize! :set_password, @user
    @user.update(user_params)
    respond_with @user, location: home_path
  end

  def destroy
    authorize! :set_password, @user
    @user.destroy
    respond_with @user, location: home_path
  end

  private

  def set_user
    @user = current_user
    raise CanCan::AccessDenied if @user.blank?
  end

  def user_params
    permitted_params = %i[default_organisation_id]
    permitted_params += %i[password password_confirmation] if params[:user][:password].present?
    params.require(:user).permit(permitted_params)
  end
end
