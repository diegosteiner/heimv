module BookingStrategy
  module Default
    class StateMachine < Base::StateMachine
      state :initial, initial: true
      %i[
        unconfirmed_request open_request provisional_request definitive_request overdue_request cancelled
        confirmed upcoming overdue active past payment_due payment_overdue completed
      ].each { |s| state(s) }

      transition from: :initial,             to: %i[unconfirmed_request provisional_request definitive_request]
      transition from: :unconfirmed_request, to: %i[cancelled open_request]
      transition from: :open_request,        to: %i[cancelled provisional_request definitive_request]
      transition from: :provisional_request, to: %i[definitive_request overdue_request cancelled]
      transition from: :overdue_request,     to: %i[cancelled definitive_request provisional_request]
      transition from: :definitive_request,  to: %i[cancelled confirmed]
      transition from: :confirmed,           to: %i[cancelled upcoming overdue]
      transition from: :overdue,             to: %i[cancelled upcoming]
      transition from: :upcoming,            to: %i[cancelled active]
      transition from: :active,              to: %i[past]
      transition from: :past,                to: %i[payment_due]
      transition from: :payment_due,         to: %i[payment_overdue completed]
      transition from: :payment_overdue,     to: %i[completed]
      transition from: :past,                to: %i[completed]

      guard_transition(to: %i[confirmed]) do |booking|
        booking.occupancy.conflicting.none?
      end

      guard_transition(to: :completed) do |booking|
        !booking.invoices.unpaid.exists?
      end

      guard_transition(to: :cancelled) do |booking|
        !booking.invoices.unpaid.exists?
      end

      after_transition(to: %i[unconfirmed_request]) do |booking|
        if booking.booking_agent.present?
          BookingMailer.booking_agent_request(BookingMailerViewModel.new(booking, booking.booking_agent.email))
                       .deliver_now
        else
          booking.messages.new_from_template(:unconfirmed_request_message)&.deliver_now
        end
      end

      after_transition(to: %i[overdue_request overdue payment_overdue]) do |booking|
        booking.deadlines.create(at: 3.days.from_now)
      end

      after_transition(to: %i[provisional_request confirmed payment_due]) do |booking|
        booking.deadlines.create(at: 14.days.from_now, extendable: 1) unless booking.deadline
      end

      after_transition(to: %i[open_request]) do |booking|
        BookingMailer.new_booking(booking).deliver_now
        booking.messages.new_from_template(:open_request_message)&.deliver_now
      end

      after_transition(to: %i[overdue_request overdue]) do |booking|
        booking.messages.new_from_template("#{booking.current_state}_message")&.deliver_now
      end

      after_transition(to: %i[provisional_request definitive_request]) do |booking|
        booking.messages.new_from_template("#{booking.current_state}_message")&.deliver_now
        booking.occupancy.tentative!
      end

      after_transition(to: %i[cancelled]) do |booking|
        booking.update(editable: false)
        booking.occupancy.free!
        booking.deadline.try(:clear)
      end

      after_transition(to: %i[confirmed]) do |booking|
        booking.update(editable: false)
        BookingStrategy::Default::Manage::Command.new(booking).email_contract_and_deposit
      end

      after_transition(to: %i[confirmed upcoming active overdue]) do |booking|
        booking.occupancy.occupied!
      end

      after_transition(to: %i[upcoming]) do |booking|
        booking.messages.new_from_template('upcoming_message')&.deliver_now
      end

      after_transition(to: %i[confirmed upcoming completed]) do |booking|
        booking.deadline.try(:clear)
      end
    end
  end
end
