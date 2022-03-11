# frozen_string_literal: true

module Manage
  class DashboardController < BaseController
    authorize_resource :booking

    def index; end
  end
end
