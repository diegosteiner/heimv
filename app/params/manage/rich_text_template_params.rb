# frozen_string_literal: true

module Manage
  class RichTextTemplateParams < ApplicationParams
    def self.permitted_keys
      %i[key home_id] + I18n.available_locales.map { |locale| ["title_#{locale}", "body_#{locale}"] }.flatten
    end

    sanitize do |params|
      sanitizer = Rails::Html::SafeListSanitizer.new
      I18n.available_locales.map do |locale|
        body_locale = "body_#{locale}"
        params[body_locale] = sanitizer.sanitize(params[body_locale])
      end
      params
    end
  end
end
