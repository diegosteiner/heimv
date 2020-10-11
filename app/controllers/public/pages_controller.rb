# frozen_string_literal: true

module Public
  class PagesController < BaseController
    def redirect
      redirect_to default_path
    end

    protected

    def current_organisation
      @current_organisation ||= Organisation.find_by(slug: params[:org].presence)
    end
  end
end
