module BookingStrategy
  module Default
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

      # guard_transition(from: :new_request, to: %i[provisional_request definitive_request]) do |booking|
      # booking.errors.add(:kind, I18n.t(:'errors.messages.blank')) if booking.event_kind.blank?
      # if booking.approximate_headcount.blank?
      #   booking.errors.add(:approximate_headcount, I18n.t(:'errors.messages.blank'))
      # end
      # booking.valid?
      # end

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
        BookingStateMailer.state_changed(booking, :confirmed_new_request).deliver_now
      end

      after_transition(to: %i[provisional_request definitive_request]) do |booking|
        booking.occupancy.update(blocking: false)
      end

      after_transition(to: %i[cancelled]) do |booking|
        booking.occupancy.update(blocking: false)
      end

      after_transition(to: %i[confirmed upcoming active overdue]) do |booking|
        booking.occupancy.update(blocking: true)
      end

      automatic_transition(from: :initial, to: :new_request) do |booking|
        booking.email.present?
      end

      automatic_transition(from: :new_request, to: :confirmed_new_request) do |booking|
        booking.customer.valid?
      end

      automatic_transition(from: :confirm_new_request, to: :provisional_request) do |booking|
        booking.customer.reservations_allowed
      end

      automatic_transition(to: :cancelled) do |booking|
        booking.cancellation_reason.present?
      end

      # automatic_transition(from: :confirmed_new_request, to: :provisional_request) do |booking|
      #   booking.valid? && !booking.committed_request.nil? && !booking.committed_request
      # end

      automatic_transition(from: :provisional_request, to: :definitive_request, &:committed_request)
    end
  end
end
