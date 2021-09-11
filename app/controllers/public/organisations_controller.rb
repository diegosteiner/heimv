# frozen_string_literal: true

module Public
  class OrganisationsController < BaseController
    before_action :set_organisation
    authorize_resource :organisation

    def show
      redirect_to homes_path
    end

    protected

    def set_organisation
      @organisation = current_organisation
    end
  end
end
