module BookingStateMachines
  class Base
    include Statesman::Machine

    state :initial, initial: true

    def prefered_transition
      raise NotImplementedError
    end
  end
end
