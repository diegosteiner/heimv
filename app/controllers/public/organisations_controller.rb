# frozen_string_literal: true

module Public
  class OrganisationsController < BaseController
    before_action :set_organisation
    authorize_resource :organisation

    def show; end

    protected

    def set_organisation
      @organisation = current_organisation
    end
  end
end
