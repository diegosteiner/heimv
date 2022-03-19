# frozen_string_literal: true

module Manage
  class RichTextTemplateParams < ApplicationParams
    def self.permitted_keys
      %i[key home_id enabled] +
        I18n.available_locales.map { |locale| ["title_#{locale}", "body_#{locale}"] }.flatten
    end

    sanitize do |params|
      I18n.available_locales.map do |locale|
        body_locale = "body_#{locale}"
        params[body_locale] = params[body_locale].yield_self do |body|
          RichTextTemplate.sanitize_html(body)
                          .gsub(/(%7B%7B|%7D%7D)/, { '%7B%7B' => '{{', '%7D%7D' => '}}' })
        end
      end
      params
    end
  end
end
