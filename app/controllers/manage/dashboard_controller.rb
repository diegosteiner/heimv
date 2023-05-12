# frozen_string_literal: true

module Manage
  class DashboardController < BaseController
    authorize_resource :organisation

    def index
      @occupiables = current_organisation.occupiables.occupiable.ordered
    end
  end
end
