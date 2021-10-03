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
      if limit_reached?
        @user.errors.add(:base, :limit_reached)
      else
        onboarding = OnboardingService.new(current_organisation)
        @user = onboarding.invite_user!(email: params.dig(:user, :email), role: user_role_param)
      end
      respond_with :manage, @user, location: manage_users_path
    end

    def update
      @user.update(organisation: current_organisation, role: user_role_param)
      respond_with :manage, @user, location: manage_users_path
    end

    def destroy
      @user.destroy unless @user == current_user
      respond_with :manage, @user, location: manage_users_path
    end

    protected

    def allowed_roles
      current_user.role_admin? ? User.roles.keys : %w[readonly manager]
    end

    private

    def user_role_param
      requested_role = params.dig(:user, :role)
      requested_role if allowed_roles.include?(requested_role)
    end

    def limit_reached?
      return false if current_organisation.users_limit.nil? ||
                      current_organisation.users_limit < current_organisation.users.count

      true
    end

    def user_params
      params[:user].permit
    end
  end
end
