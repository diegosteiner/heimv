# frozen_string_literal: true

module Public
  class OrganisationsController < BaseController
    before_action :set_organisation

    def show
      respond_to do |format|
        format.html { redirect_to homes_path }
        format.json { render json: OrganisationSerializer.render_as_json(@organisation) }
      end
    end

    protected

    def set_organisation
      @organisation = current_organisation
    end
  end
end
