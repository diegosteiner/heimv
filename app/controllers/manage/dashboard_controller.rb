# frozen_string_literal: true

module Manage
  class DashboardController < BaseController
    authorize_resource :organisation

    def index
      @dashboard = ManageDashboardData.new(current_organisation)
    end
  end
end
