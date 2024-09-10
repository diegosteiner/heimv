# frozen_string_literal: true

module Public
  class BaseController < ApplicationController
    before_action :require_organisation!

    protected

    def current_ability
      @current_ability ||= Ability::Public.new(current_user, current_organisation)
    end

    def allow_embed
      response.set_header('X-Frame-Options', 'ALLOWALL')
    end

    def allow_cors
      allowed_origins = current_organisation.cors_origins&.lines || []
      response.set_header('Access-Control-Allow-Origin', request.origin) if allowed_origins.include?(request.origin)
    end
  end
end
