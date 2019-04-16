module BookingStrategies
  class Default < BookingStrategy
    def public_actions
      Actions::Public
    end

    def manage_actions
      Actions::Manage
    end

    def state_machine
      StateMachine
    end

    def checklist
      Checklist
    end

    def t(state, options = {})
      I18n.t(state, options.merge(scope: i18n_scope + Array.wrap(options[:scope])))
    end

    def booking_actions
      self::Actions
    end

    def state_machine_automator
      StateMachineAutomator
    end
  end
end
