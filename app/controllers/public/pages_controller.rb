# frozen_string_literal: true

module Public
  class PagesController < BaseController
    def redirect
      redirect_to default_path
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
