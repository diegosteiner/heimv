module BookingStrategies
  class Default
    # rubocop:disable Metrics/ClassLength
    class StateMachine < BookingStrategy::StateMachine
      state :initial, initial: true
      %i[
        cancelled_request declined_request booking_agent_request awaiting_tenant
        unconfirmed_request open_request provisional_request definitive_request overdue_request cancelled
        confirmed upcoming overdue active past payment_due payment_overdue completed cancelation_pending
      ].each { |s| state(s) }

      # TODO: definitive -> accepted_definitive_request,
      # upcoming_soon,
      # confirmed -> awaiting_contract,
      #

      transition from: :initial,
                 to: %i[unconfirmed_request provisional_request definitive_request open_request]

      transition from: :unconfirmed_request,
                 to: %i[cancelled_request declined_request open_request]

      transition from: :open_request,
                 to: %i[cancelled_request declined_request
                        provisional_request definitive_request booking_agent_request]

      transition from: :provisional_request,
                 to: %i[definitive_request overdue_request cancelled_request declined_request]

      transition from: :overdue_request,
                 to: %i[cancelled_request declined_request definitive_request provisional_request
                        booking_agent_request awaiting_tenant]

      transition from: :booking_agent_request,
                 to: %i[cancelled_request declined_request awaiting_tenant overdue_request]

      transition from: :awaiting_tenant,
                 to: %i[definitive_request overdue_request cancelled_request declined_request overdue_request]

      transition from: :definitive_request,  to: %i[cancelation_pending confirmed]
      transition from: :confirmed,           to: %i[cancelation_pending upcoming overdue]
      transition from: :overdue,             to: %i[cancelation_pending upcoming]
      transition from: :upcoming,            to: %i[cancelation_pending active]
      transition from: :active,              to: %i[past]
      transition from: :past,                to: %i[payment_due]
      transition from: :payment_due,         to: %i[payment_overdue completed]
      transition from: :payment_overdue,     to: %i[completed]
      transition from: :past,                to: %i[completed]
      transition from: :cancelation_pending, to: %i[cancelled]

      guard_transition(to: %i[confirmed]) do |booking|
        booking.occupancy.conflicting.none?
      end

      guard_transition(to: :definitive_request) do |booking|
        booking.tenant.present? && booking.tenant.valid?
      end

      guard_transition(to: :completed) do |booking|
        !booking.invoices.unpaid.exists?
      end

      guard_transition(to: :cancelled) do |booking|
        !booking.invoices.unpaid.exists?
      end

      guard_transition(to: %i[booking_agent_request awaiting_tenant]) do |booking|
        !booking.agent_booking?
      end

      after_transition(to: %i[unconfirmed_request]) do |booking|
        booking.messages.new_from_template(:unconfirmed_request_message, addressed_to: :tenant).deliver_now
      end

      after_transition(to: %i[awaiting_tenant]) do |booking|
        booking.messages.new_from_template(:awaiting_tenant_message, addressed_to: :tenant).deliver_now
        booking.messages.new_from_template(:booking_agent_request_accepted_message,
                                           addressed_to: :booking_agent).deliver_now
      end

      after_transition(to: %i[unconfirmed_request overdue_request overdue payment_overdue awaiting_tenant]) do |booking|
        booking.deadlines.create(at: booking.organisation.short_deadline.from_now, remarks: booking.state)
      end

      after_transition(to: %i[provisional_request confirmed booking_agent_request]) do |booking|
        unless booking.deadline
          booking.deadlines.create(at: booking.organisation.long_deadline.from_now,
                                   extendable: 1,
                                   remarks: booking.state)
        end
      end

      after_transition(to: %i[definitive_request]) do |booking|
        booking.editable!(false)
        booking.deadline&.clear
      end

      after_transition(to: %i[open_request]) do |booking|
        booking.deadline&.clear
        booking.messages.new_from_template(:manage_new_booking_mail, addressed_to: :manager).deliver_now
        booking.messages.new_from_template(:open_request_message, addressed_to: :tenant).deliver_now
      end

      after_transition(to: %i[overdue_request overdue]) do |booking|
        booking.messages.new_from_template("#{booking.current_state}_message", addressed_to: :tenant).deliver_now
      end

      after_transition(to: %i[booking_agent_request]) do |booking|
        booking.messages.new_from_template(:booking_agent_request_message, addressed_to: :booking_agent).deliver_now
        booking.occupancy.tentative!
      end

      after_transition(to: %i[provisional_request definitive_request]) do |booking|
        booking.messages.new_from_template("#{booking.current_state}_message", addressed_to: :tenant).deliver_now
        booking.occupancy.tentative!
      end

      before_transition(to: %i[cancelation_pending cancelled_request declined_request]) do |booking|
        booking.editable!(false)
        booking.occupancy.free!
      end

      after_transition(to: %i[cancelation_pending cancelled_request declined_request]) do |booking|
        booking.deadline.try(:clear)
      end

      after_transition(to: %i[confirmed upcoming active overdue]) do |booking|
        booking.occupancy.occupied!
      end

      after_transition(to: %i[upcoming]) do |booking|
        booking.messages.new_from_template(:upcoming_message, addressed_to: :tenant).deliver_now
      end

      after_transition(to: %i[payment_due]) do |booking|
        invoice = booking.invoices.sent.unpaid.order(payable_until: :asc).last
        payable_until = invoice&.payable_until || 30.days.from_now
        booking.deadlines.create(at: payable_until, extendable: 1) unless booking.deadline
      end

      after_transition(to: %i[payment_overdue]) do |booking|
        booking.messages.new_from_template(:payment_overdue_message, addressed_to: :tenant).deliver_now
      end

      after_transition(to: %i[confirmed upcoming completed]) do |booking|
        booking.deadline.try(:clear)
      end

      after_transition(to: %i[cancelled]) do |booking|
        booking.messages.new_from_template(:cancelled_message, addressed_to: :tenant).deliver_now
        if booking.agent_booking?
          booking.messages.new_from_template(:booking_agent_cancelled_message, addressed_to: :booking_agent).deliver_now
        end
      end

      after_transition(to: %i[cancelled_request]) do |booking|
        addressed_to = booking.agent_booking? ? :booking_agent : :tenant
        booking.messages.new_from_template(:cancelled_request_message, addressed_to: addressed_to).deliver_now
      end

      after_transition(to: %i[declined_request]) do |booking|
        addressed_to = booking.agent_booking? ? :booking_agent : :tenant
        booking.messages.new_from_template(:declined_request_message, addressed_to: addressed_to).deliver_now
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
