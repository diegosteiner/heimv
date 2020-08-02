# frozen_string_literal: true

module Public
  class BaseController < ApplicationController
    def current_ability
      @current_ability ||= Ability::Public.new(current_user)
    end

    protected

    def allow_embed
      response.set_header('X-Frame-Options', 'ALLOWALL')
    end
  end
end
