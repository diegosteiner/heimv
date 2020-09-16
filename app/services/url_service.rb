# frozen_string_literal: true

class UrlService
  include Singleton
  include Rails.application.routes.url_helpers
end
