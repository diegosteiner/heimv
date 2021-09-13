# frozen_string_literal: true

module Public
  class PagesController < BaseController
    def redirect
      redirect_to default_path
    end

    def changelog; end

    def privacy; end

    def ext
      respond_to do |format|
        format.js render(file: helpers.asset_pack_path('ext'))
      end
    end

    protected

    def current_organisation
      @current_organisation ||= Organisation.find_by(slug: params[:org].presence)
    end
  end
end
