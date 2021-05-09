# frozen_string_literal: true

module Manage
  class UsersController < BaseController
    load_and_authorize_resource :user
    helper_method :allowed_roles

    def index
      @users = @users.where(organisation: current_organisation)
      respond_with :manage, @users
    end

    def edit
      respond_with :manage, @user
    end

    def new
      respond_with :manage, @user
    end

    def create
      @user.update(user_params.merge(organisation: current_organisation, role: user_role_param)) unless enforce_limit
      respond_with :manage, @user, location: manage_users_path
    end

    def update
      @user.update(user_params.merge(organisation: current_organisation, role: user_role_param))
      respond_with :manage, @user, location: manage_users_path
    end

    def destroy
      @user.destroy unless @user == current_user
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

    def enforce_limit
      return false if current_organisation.users_limit.nil? ||
                      current_organisation.users_limit < current_organisation.users.count

      @user.errors.add(:base, :limit_reached)
      true
    end

    def user_params
      UserParams.new(params.require(:user)).permitted(params[:password].present? ? [:password] : [])
    end
  end
end
