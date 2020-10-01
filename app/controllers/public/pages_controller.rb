# frozen_string_literal: true

module Public
  class PagesController < BaseController
    def home
      return if current_organisation.present?
      return redirect_to new_user_session_path if current_user.blank?
      return redirect_to admin_root_path if current_user.role_admin?

      raise ActionController::RoutingError
    end

    def ext
      respond_to do |format|
        format.js render file: helpers.asset_pack_path('ext')
      end
    end

    protected

    def current_organisation
      @current_organisation ||= Organisation.find_by(slug: params[:org].presence)
    end
  end
end
