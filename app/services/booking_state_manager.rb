class BookingStateManager
  attr_accessor :booking

  delegate :transition_to, :can_transition_to?, :transition_to!, :current_state, :allowed_transitions, :in_state?,
           :prefered_transition, :automatic, :allowed_public_transitions, to: :state_machine

  def initialize(booking)
    @booking = booking
  end

  def state_machine
    @state_machine ||= state_machine_class.new(booking, transition_class: booking.booking_transitions.klass)
  end

  def state_machine_class
    BookingStrategy::Default::StateMachine
  end
end
