# frozen_string_literal: true

module Public
  class BaseController < ApplicationController
    protected

    def current_organisation
      @current_organisation ||= Organisation.find_by!(slug: params[:org].presence)
    end

    def current_ability
      @current_ability ||= Ability::Public.new(current_user, current_organisation)
    end

    def allow_embed
      response.set_header('X-Frame-Options', 'ALLOWALL')
    end
  end
end
