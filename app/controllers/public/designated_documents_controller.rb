# frozen_string_literal: true

module Public
  class DesignatedDocumentsController < BaseController
    include ActionController::Live

    def show
      response.headers['Content-Type'] = document.file.content_type

      document.file.download do |chunk|
        response.stream.write(chunk)
      end
    ensure
      response.stream.close
    end

    private

    def document
      context = current_organisation
      context = current_organisation.homes.find!(params[:home_id]) if params[:home_id]
      @document ||= DesignatedDocument.in_context(context).with_locale(I18n.locale)
                                      .where(designation: params[:designation])
                                      .order(home_id: :asc, locale: :asc).first
    end
  end
end
