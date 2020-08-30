# frozen_string_literal: true

module Public
  class PagesController < BaseController
    def home
      return if current_organisation && current_user&.organisation != current_organisation

      redirect_to redirection_target
    end

    def ext
      respond_to do |format|
        format.js render file: helpers.asset_pack_path('ext')
      end
    end

    protected

    def redirection_target
      return new_user_session_path if current_organisation.blank? && current_user.blank?
      return admin_root_path if current_user.role_admin?
      return manage_root_path if current_user.role_manager?

      '/404'
    end
  end
end
