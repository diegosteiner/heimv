# frozen_string_literal: true

module Translatable
  extend ActiveSupport::Concern

  included do
    def i18n_scope
      self.class.i18n_scope
    end

    def translated(key = :label, options = {})
      I18n.t(key, options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
    end
    alias_method :t, :translated
  end

  class_methods do
    def i18n_scope
      name.split('::').map(&:underscore)
    end

    def translated(key = :label, options = {})
      I18n.t(key, options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
    end
    alias_method :t, :translated
  end
end
