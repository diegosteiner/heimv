module BookingStrategy
  module Base
    extend WithTemplate

    def i18n_scope
      name.split('::').map(&:underscore)
    end

    def t(state, options = {})
      I18n.t(state, options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
    end
  end
end
