# frozen_string_literal: true

module Translatable
  extend ActiveSupport::Concern

  included do
    def i18n_scope
      self.class.i18n_scope
    end

    def translated(key = 'label')
      self.class.translated(key)
    end
    alias_method :t, :translated
  end

  class_methods do
    def i18n_scope
      name.split('::').map(&:underscore)
    end

    def translated(key = 'label')
      I18n.translate((i18n_scope + Array.wrap(key)).join('.'))
    end
    alias_method :t, :translated
  end
end
