module BookingStrategy
  class Base
    extend TemplateRenderable
    extend Translatable

    class << self
      # TODO move
      def t(state, options = {})
        I18n.t(state, options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
      end

      def booking_actions
        self::BookingActions
      end
    end
  end
end
