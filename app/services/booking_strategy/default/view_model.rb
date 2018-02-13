module BookingStrategy
  module Default
    class ViewModel < BookingViewModel
      I18N_SCOPE = [:booking_strategy, :default, :state].freeze

      def current_state_help
        tk = I18N_SCOPE + [booking.state_machine.current_state]
        I18n.t(:label, scope: tk)
      end

      def allowed_transitions_for_select; end

      def homes_for_select
        Home.all
      end


    end
  end
end
