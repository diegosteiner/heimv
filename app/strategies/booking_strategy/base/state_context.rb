module BookingStrategy
  module Base
    class StateContext
      attr_reader :actions, :booking
      delegate :deadline, to: :booking

      Text = Struct.new(:key)
      LinkTo = Struct.new(:key, :options)
      ButtonTo = Struct.new(:key, :action, :method, :params)

      def initialize(booking)
        @booking = booking
        @actions = self.class.state_actions[booking.state_machine.current_state.to_sym]&.call(booking) || []
      end

      def deadline?
        deadline.present?
      end

      class << self
        include Rails.application.routes.url_helpers
        attr_reader :state_actions

        def actions_for(state, &block)
          @state_actions ||= {}
          @state_actions[state] = block
        end
      end

    end
  end
end

