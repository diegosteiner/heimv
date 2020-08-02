# frozen_string_literal: true

module Manage
  class BaseController < ::ApplicationController
    before_action :authenticate_user!
    check_authorization

    def current_ability
      @current_ability ||= Ability::Manage.new(current_user)
    end
  end
end
