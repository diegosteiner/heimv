class BookingStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :awaiting_preconditions
  state :reserved
  state :awaiting_postconditions
  state :completed
  state :cancelled

  transition from: :pending, to: %i[awaiting_preconditions cancelled]
  transition from: :awaiting_preconditions, to: %i[reserved cancelled]
  transition from: :reserved, to: %i[awaiting_postconditions cancelled]
  transition from: :awaiting_postconditions, to: :completed

  guard_transition(to: :reserved) do |booking|
    begin
    booking.contracts.any? &&
      booking.contracts.all?(:signed?) &&
      booking.bills.deposits.all?(:payed?)
  rescue NoMethodError
    next true
  end
  end

  guard_transition(to: :completed) do |booking|
    begin
    booking.contracts.all?(:signed?) &&
      booking.bills.all?(:payed?)
  rescue NoMethodError
    next true
  end
  end

  def allowed_or_current_transitions
    allowed_transitions + [current_state]
  end

  def self.states_enum_hash
    Hash[states.map { |state| [state.to_sym, state] }]
  end
end
