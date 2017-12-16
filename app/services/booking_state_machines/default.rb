module BookingStateMachines
  class Default < Base
    state :initial, initial: true
    STATES = %i[
      new_request provisional_request definitive_request overdue_request cancelled
      confirmed upcoming overdue active past payment_due payment_overdue completed
    ].freeze
    STATES.each { |s| state(s) }

    transition from: :initial, to: %i[new_request provisional_request definitive_request]
    transition from: :overdue_request, to: %i[cancelled definitive_request provisional_request]
    transition from: :new_request, to: %i[cancelled provisional_request definitive_request]
    transition from: :provisional_request, to: %i[definitive_request overdue_request cancelled]
    transition from: :definitive_request, to: %i[cancelled confirmed]
    transition from: :confirmed, to: %i[confirmed cancelled upcoming overdue]
    transition from: :overdue, to: %i[cancelled upcoming]
    transition from: :upcoming, to: %i[cancelled upcoming active]
    transition from: :active, to: %i[past]
    transition from: :past, to: %i[payment_due]
    transition from: :payment_due, to: %i[payment_due payment_overdue completed]
    transition from: :payment_overdue, to: %i[payment_overdue completed]

    guard_transition(to: :upcoming) do |booking|
      booking.contracts.any? &&
        booking.contracts.all?(&:signed?) &&
        booking.bills.deposits.all?(&:payed_or_prolonged?)
    end

    guard_transition(to: :completed) do |booking|
      booking.bills.any? &&
        booking.bills.open.none?
    end

    guard_transition(to: :cancelled) do |booking|
      booking.bills.open.none?
    end
  end
end
