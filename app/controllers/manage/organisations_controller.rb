# frozen_string_literal: true

module Manage
  class OrganisationsController < BaseController
    load_and_authorize_resource :organisation
    before_action :set_organisation

    def show
      respond_to do |format|
        format.html { redirect_to manage_root_path }
        format.json { render json: Manage::OrganisationSerializer.render(@organisation) }
      end
    end

    def edit; end

    def update
      @organisation.update(organisation_params)
      respond_with :manage, @organisation, location: edit_manage_organisation_path
    end

    private

    def set_organisation
      @organisation = current_organisation
    end

    def organisation_params
      return params.require(:organisation).permit(OrganisationParams.admin_permitted_keys) if current_user.role_admin?

      OrganisationParams.new(params[:organisation]).permitted
    end
  end
end
