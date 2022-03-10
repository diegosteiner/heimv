# frozen_string_literal: true

module Public
  class BaseController < ApplicationController
    # skip_before_action :verify_authenticity_token
    # before_action :disable_cookies
    before_action :require_organisation!

    protected

    def current_ability
      @current_ability ||= Ability::Public.new(current_user, current_organisation)
    end

    def allow_embed
      response.set_header('X-Frame-Options', 'ALLOWALL')
    end
  end
end
