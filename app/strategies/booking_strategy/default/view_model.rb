module BookingStrategy
  class Default
    class ViewModel < BookingViewModel
      I18N_SCOPE = %i[booking_strategy default].freeze

      def current_state_help
        self.class.i18n_state(@booking.state_machine.current_state)[:label]
      end

      def allowed_transitions_for_select
        transitions = @booking.state_machine.allowed_transitions.map do |transition|
          [self.class.i18n_state(transition)[:label], transition]
        end
        ActionController::Base.helpers.options_for_select(transitions)
      end

      def homes_for_select(homes = Home.all)
        ActionController::Base.helpers.options_for_select(homes.map { |h| [h.to_s, h.to_param] }, @booking.home_id)
      end

      def self.i18n_state(state)
        I18n.t(state, scope: I18N_SCOPE + [:state])
      end

      def self.i18n_transition(from = nil, to)
        scope = I18N_SCOPE + [:transition]
        I18n.t("#{from}-->#{to}", scope: scope, raise: true)
      rescue I18n::MissingTranslationData
        I18n.t("-->#{to}", scope: scope, raise: true)
      end
    end
  end
end
