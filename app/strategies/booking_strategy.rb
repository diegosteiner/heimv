class BookingStrategy
  extend TemplateRenderable
  extend Translatable

  class << self
    # TODO: move
    def t(state, options = {})
      I18n.t(state, options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
    end

    def booking_actions
      self::BookingActions
    end

    def infer(_booking)
      BookingStrategies::Default
    end

    alias [] infer
end
end
