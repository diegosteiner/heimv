# frozen_string_literal: true

module Translatable
  def translatable_scope
    name = is_a?(Class) ? self.name : self.class.name
    name.split('::').map(&:underscore)
  end

  def translate(key = :label, options = {})
    scope = translatable_scope + Array.wrap(options.delete(:scope))
    I18n.t(key, options.reverse_merge(scope: scope, default: nil))
  end
  alias t translate
end
