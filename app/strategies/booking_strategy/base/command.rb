module BookingStrategy
  module Base
    class Command
      def initialize(booking)
        @booking = booking
      end

      def exec(command_str)
        return false unless @booking.valid? && command_str && respond_to?(command_str)

        send(command_str)
      end

    end
  end
end
