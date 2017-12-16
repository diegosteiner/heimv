module BookingStateMachines
  class Base
    include Statesman::Machine

    state :initial, initial: true

    def allowed_or_current_transitions
      allowed_transitions + [current_state]
    end
  end
end
