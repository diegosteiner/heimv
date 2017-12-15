module StateMachines
  class ApplicationStateMachine
    include Statesman::Machine

    def allowed_or_current_transitions
      allowed_transitions + [current_state]
    end

    def self.states_enum_hash
      Hash[states.map { |state| [state.to_sym, state] }]
    end
  end
end
