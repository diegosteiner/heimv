# frozen_string_literal: true

module Manage
  class BaseController < ApplicationController
    before_action :require_user!, :require_organisation!
    check_authorization

    protected

    def current_ability
      @current_ability ||= Ability::Manage.new(current_user, current_organisation)
    end
  end
end
