module BookingStrategy
  module Base
    class Instance
      def initialize(booking)
        @booking = booking
      end

      def render_service
        @render_service ||= RenderService.new(@booking)
      end

      def state_manager
        @state_manager ||= StateManager.new(@booking)
      end
    end
  end
end
