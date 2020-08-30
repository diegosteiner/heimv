# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    skip_authorization_check

    def index; end
  end
end
