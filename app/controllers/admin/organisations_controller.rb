# frozen_string_literal: true

module Admin
  class OrganisationsController < BaseController
    load_and_authorize_resource :organisation
    # after_action :attach_files, only: :update

    def index; end

    def edit; end

    def update
      @organisation.update(organisation_params)
      respond_with :admin, @organisation, location: edit_admin_organisation_path
    end

    def show
      redirect_to edit_admin_organisation_path
    end

    def new
      respond_with :admin, @organisation
    end

    def create
      @organisation.save
      respond_with :admin, @organisation
    end

    private

    def organisation_params
      OrganisationParams.new(params[:organisation])
    end
  end
end
