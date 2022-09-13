# frozen_string_literal: true

module Public
  class PagesController < BaseController
    skip_before_action :require_organisation!, only: :home

    def home
      return redirect_to new_user_session_path if current_user.blank?
      return redirect_to home_path if current_organisation || current_user.default_organisation

      @organisations = current_user.organisation_users.map(&:organisation)
    end

    def changelog; end

    def privacy
      @privacy_statement = DesignatedDocument.in_context(current_organisation).with_locale(I18n.locale)
                                             .privacy_statement.first
    end

    def ext
      respond_to do |format|
        format.js render(file: helpers.asset_pack_path('ext'))
      end
    end
  end
end
