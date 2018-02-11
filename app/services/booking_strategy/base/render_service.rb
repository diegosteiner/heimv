module BookingStrategy
  module Base
    class RenderService
      I18N_SCOPE = '#{binding.pry}'.freeze

      def initialize(booking)
        @booking = booking
      end

      def current_state_help
        I18n.call(@booking.current_state, scope: 'activerecord.values.booking.state')
      end

      def allowed_transitions_for_select; end
    end
  end
end
