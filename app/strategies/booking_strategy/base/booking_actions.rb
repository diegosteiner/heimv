module BookingStrategy
  class Base
    module BookingActions
      def self.available_actions(booking, publicly_available_only: false)
        self::ACTIONS.values.select do |action_klass|
          # (publicly_available_only && !action_klass.publicly_available?)
          action_klass.available_on?(booking)
        end.map(&:new)
      end

      def self.[](action_name, publicly_available_only: false)
        action_klass = self::ACTIONS[action_name]
        return if !action_klass || (publicly_available_only && !action_klass.publicly_available?)

        action_klass.new
      end

      class Base
        extend Translatable

        def call(booking); end

        def self.action_name
          name.demodulize.underscore
        end

        def to_s
          self.class.action_name
        end

        def self.publicly_available?
          false
        end

        def variant
          :primary
        end
      end
    end
  end
end
