# frozen_string_literal: true

module Manage
  class RichTextTemplateParams < ApplicationParamsSchema
    define do
      optional(:key).filled(:string)
      optional(:enabled).filled(:bool)
      optional(:autodeliver).filled(:bool)

      I18n.available_locales.map do |locale|
        optional(:"title_#{locale}").maybe(:string)
        optional(:"body_#{locale}").maybe(:string)
      end

      after(:rule_applier) do |result|
        result.to_h.tap do |params|
          I18n.available_locales.map do |locale|
            body_locale = :"body_#{locale}"
            params[body_locale] = RichTextSanitizer.sanitize(params[body_locale])
          end
        end
      end
    end
  end
end
