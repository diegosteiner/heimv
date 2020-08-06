# frozen_string_literal: true

module Admin
  class BaseController < ::ApplicationController
    before_action :authenticate_user!
    check_authorization

    def current_ability
      @current_ability ||= Ability::Admin.new(current_user)
    end
  end
end
