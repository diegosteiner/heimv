# frozen_string_literal: true

class ApplicationSerializer < Blueprinter::Base
  def self.url
    @url ||= Class.new { include Rails.application.routes.url_helpers }.new
  end
end
