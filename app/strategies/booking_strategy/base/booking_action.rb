module BookingStrategy
  class Base
    class BookingAction
      extend Translatable

      def call(booking)
      end

      def self.action_name
        self.name.demodulize.underscore
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
