class BookingStrategy
  class StateMachine
    extend TemplateRenderable
    include Statesman::Machine

    def state_object
      object.organisation.booking_strategy.booking_states[current_state&.to_sym]&.new(object)
    end
  end
end
