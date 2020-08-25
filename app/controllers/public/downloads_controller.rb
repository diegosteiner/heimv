# frozen_string_literal: true

module Public
  class DownloadsController < BaseController
    include ActionController::Live
    before_action :set_download

    def show
      response.headers['Content-Type'] = @download.content_type

      @download.download do |chunk|
        response.stream.write(chunk)
      end
    ensure
      response.stream.close
    end

    private

    def set_download
      @download = case params[:slug]&.downcase
                  when t(:terms_pdf, scope: %i[downloads slug])
                    current_organisation.terms_pdf
                  when t(:privacy_statement_pdf, scope: %i[downloads slug])
                    current_organisation.privacy_statement_pdf
                  end

      raise ActionController::RoutingError, 'File not found' if @download.blank?
    end
  end
end
