# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      authorize! :manage, :all
    end
  end
end
