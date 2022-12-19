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
      @document ||= current_organisation.designated_documents
                                        .where(designation: params[:designation])
                                        .with_locale(I18n.locale).take!
    end
  end
end
