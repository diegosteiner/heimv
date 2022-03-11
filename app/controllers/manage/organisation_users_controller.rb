# frozen_string_literal: true

module Manage
  class OrganisationUsersController < BaseController
    load_and_authorize_resource :organisation_user
    helper_method :allowed_roles

    def index
      @organisation_users = @organisation_users.where(organisation: current_organisation)
      respond_with :manage, @organisation_users
    end

    def edit
      respond_with :manage, @organisation_user
    end

    def new
      respond_with :manage, @organisation_user
    end

    def create
      if limit_reached?
        @organisation_user.errors.add(:base, :limit_reached)
      else
        onboarding = OnboardingService.new(current_organisation)
        email = params.dig(:organisation_user, :email)
        @organisation_user = onboarding.add_or_invite_user!(email: email, role: organisation_user_params[:role])
      end
      respond_with :manage, @organisation_user, location: manage_organisation_users_path
    end

    def update
      @organisation_user.update(organisation_user_params)
      respond_with :manage, @organisation_user, location: manage_organisation_users_path
    end

    def destroy
      @organisation_user.destroy unless @organisation_user == current_user
      respond_with :manage, @organisation_user, location: manage_organisation_users_path
    end

    protected

    def allowed_roles
      current_user.role_admin? ? OrganisationUser.roles.keys : %w[readonly manager]
    end

    private

    def role_param; end

    def limit_reached?
      return false if current_organisation.users_limit.nil? ||
                      current_organisation.users_limit < current_organisation.users.count

      true
    end

    def organisation_user_params
      permitted_params = []
      requested_role = params.dig(:organisation_user, :role)
      permitted_params << :role if allowed_roles.include?(requested_role)
      params[:organisation_user].permit(permitted_params)
    end
  end
end
