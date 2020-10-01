# frozen_string_literal: true

module Manage
  class UsersController < BaseController
    load_and_authorize_resource :user
    helper_method :allowed_roles

    def index
      respond_with :manage, @users
    end

    def edit
      respond_with :manage, @user
    end

    def new
      respond_with :manage, @user
    end

    def create
      @user.update(user_params.merge(organisation: current_organisation, role: user_role_param))
      respond_with :manage, @user, location: manage_users_path
    end

    def update
      @user.update(user_params.merge(organisation: current_organisation, role: user_role_param))
      respond_with :manage, @user, location: manage_users_path
    end

    def destroy
      @user.destroy
      respond_with :manage, @user, location: manage_users_path
    end

    protected

    def allowed_roles
      %w[user manager]
    end

    private

    def user_role_param
      requested_role = user_params[:role]
      requested_role if allowed_roles.include?(requested_role)
    end

    def user_params
      UserParams.new(params.require(:user)).permitted
    end
  end
end
