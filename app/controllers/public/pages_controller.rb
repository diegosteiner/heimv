# frozen_string_literal: true

module Public
  class PagesController < BaseController
    skip_before_action :require_organisation!, only: %i[home health]

    def home
      return redirect_to new_user_session_path if current_user.blank? && current_organisation.blank?
      return redirect_to home_path if current_organisation || current_user.default_organisation

      @organisations = Organisation.accessible_by(current_ability).ordered
    end

    def health
      check = HealthService.new
      render json: check.to_h, status: check.ok? ? 200 : 500
    end

    def changelog; end

    def privacy
      privacy_statement = current_organisation.designated_documents.with_locale(I18n.locale)
                                              .privacy_statement.first

      raise ActionController::RoutingError, 'Not Found' if privacy_statement.blank?

      redirect_to url_for(privacy_statement.file)
    end

    def ext
      respond_to do |format|
        format.js render(file: helpers.asset_pack_path('ext'))
      end
    end
  end
end
