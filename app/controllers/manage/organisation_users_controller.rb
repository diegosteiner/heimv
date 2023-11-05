# frozen_string_literal: true

module Manage
  class OrganisationUsersController < BaseController
    load_and_authorize_resource :organisation_user
    helper_method :allowed_roles

    def index
      @organisation_users = @organisation_users.where(organisation: current_organisation)
      respond_with :manage, @organisation_users
    end

    def new
      respond_with :manage, @organisation_user
    end

    def edit
      respond_with :manage, @organisation_user
    end

    def create
      if limit_reached?
        @organisation_user.errors.add(:base, :limit_reached)
      else
        email = params.dig(:organisation_user, :email)
        onboarding = OnboardingService.new(current_organisation)
        @organisation_user = onboarding.add_or_invite_user!(email:, role: organisation_user_params[:role],
                                                            invited_by: current_user)
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

    private

    def role_param; end

    def limit_reached?
      current_organisation.users_limit.present? &&
        current_organisation.organisation_users.count > current_organisation.users_limit
    end

    def organisation_user_params
      params[:organisation_user].permit(:role)
    end
  end
end
