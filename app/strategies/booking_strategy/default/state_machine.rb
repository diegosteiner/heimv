module BookingStrategy
  class Default
    class StateMachine < Base::StateMachine
      state :initial, initial: true
      %i[
        new_request confirmed_new_request provisional_request definitive_request overdue_request cancelled
        confirmed upcoming overdue active past payment_due payment_overdue completed
      ].each { |s| state(s) }

      transition from: :initial, to: %i[new_request provisional_request definitive_request]
      transition from: :overdue_request, to: %i[cancelled definitive_request provisional_request]
      transition from: :new_request, to: %i[cancelled confirmed_new_request]
      transition from: :confirmed_new_request, to: %i[cancelled provisional_request definitive_request]
      transition from: :provisional_request, to: %i[definitive_request overdue_request cancelled]
      transition from: :definitive_request, to: %i[cancelled confirmed]
      transition from: :confirmed, to: %i[cancelled upcoming overdue]
      transition from: :overdue, to: %i[cancelled upcoming]
      transition from: :upcoming, to: %i[cancelled active]
      transition from: :active, to: %i[past]
      transition from: :past, to: %i[payment_due]
      transition from: :payment_due, to: %i[payment_overdue completed]
      transition from: :payment_overdue, to: %i[completed]
      transition from: :past, to: %i[completed]

      guard_transition(to: :upcoming) do |_booking|
        true
        # booking.contracts.any? &&
        #   booking.contracts.all?(&:signed?) &&
        #   booking.bills.deposits.all?(&:payed_or_prolonged?)
      end

      guard_transition(to: :completed) do |_booking|
        true
        # booking.bills.any? &&
        #   booking.bills.open.none?
      end

      guard_transition(to: :cancelled) do |_booking|
        true
        # booking.bills.open.none?
      end

      after_transition(to: %i[new_request]) do |booking|
        if booking.booking_agent.present?
          BookingMailer.booking_agent_request(BookingMailerViewModel.new(booking, booking.booking_agent.email))
                       .deliver_now
        else
          BookingStateMailer.state_changed(booking, :new_request).deliver_now
        end
      end

      after_transition(to: %i[confirmed_new_request]) do |booking|
        BookingMailer.new_booking(booking).deliver_now
        BookingStateMailer.state_changed(booking, :confirmed_new_request).deliver_now
      end

      after_transition(to: %i[provisional_request definitive_request]) do |booking|
        booking.occupancy.tentative!
      end

      after_transition(to: %i[cancelled]) do |booking|
        booking.occupancy.free!
      end

      after_transition(to: %i[confirmed]) do |booking|
        # This does not belong here, should be called when creating a new contract
        # TarifBuilder.new.for_booking(booking).all?(&:save)
        # binding.pry
      end

      after_transition(to: %i[confirmed upcoming active overdue]) do |booking|
        booking.occupancy.occupied!
      end
    end
  end
end
