# frozen_string_literal: true

module BookingStrategies
  class Default
    # rubocop:disable Metrics/ClassLength
    class StateMachine < BookingStrategy::StateMachine
      state :initial, initial: true
      %i[
        unconfirmed_request open_request provisional_request definitive_request booking_agent_request overdue_request
        awaiting_tenant awaiting_contract overdue upcoming_soon active past payment_due payment_overdue
        cancelation_pending upcoming completed cancelled_request declined_request cancelled
      ].each { |s| state(s) }

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
                 to: %i[cancelled_request declined_request definitive_request awaiting_tenant]

      transition from: :booking_agent_request,
                 to: %i[cancelled_request declined_request awaiting_tenant overdue_request]

      transition from: :awaiting_tenant,
                 to: %i[definitive_request overdue_request cancelled_request declined_request overdue_request]

      transition from: :definitive_request, to: %i[cancelation_pending awaiting_contract]
      transition from: :awaiting_contract, to: %i[cancelation_pending upcoming overdue]
      transition from: :overdue,             to: %i[cancelation_pending upcoming]
      transition from: :upcoming,            to: %i[cancelation_pending upcoming_soon]
      transition from: :upcoming_soon,       to: %i[cancelation_pending active]
      transition from: :active,              to: %i[past]
      transition from: :past,                to: %i[payment_due]
      transition from: :payment_due,         to: %i[payment_overdue completed]
      transition from: :payment_overdue,     to: %i[completed]
      transition from: :past,                to: %i[completed]
      transition from: :cancelation_pending, to: %i[cancelled overdue]

      guard_transition(to: %i[awaiting_contract]) do |booking|
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
        booking.agent_booking.present?
      end

      after_transition(to: %i[unconfirmed_request]) do |booking|
        booking.occupancy.tentative!
        booking.notifications.new(from_template: :unconfirmed_request, addressed_to: :tenant).deliver
      end

      after_transition(to: %i[awaiting_tenant]) do |booking|
        booking.notifications.new(from_template: :awaiting_tenant, addressed_to: :tenant).deliver
        booking.notifications.new(from_template: :booking_agent_request_accepted,
                                  addressed_to: :booking_agent).deliver
      end

      after_transition(to: %i[unconfirmed_request overdue_request awaiting_tenant]) do |booking|
        booking.deadline&.clear
        booking.deadlines.create(at: booking.organisation.short_deadline.from_now, remarks: booking.state)
      end

      after_transition(to: %i[provisional_request awaiting_contract]) do |booking|
        booking.deadline&.clear
        booking.deadlines.create(at: booking.organisation.long_deadline.from_now,
                                 postponable_for: booking.organisation.short_deadline,
                                 remarks: booking.state)
      end

      after_transition(to: %i[booking_agent_request]) do |booking|
        booking.deadline&.clear
        booking.deadlines.create(at: booking.booking_agent.request_deadline_minutes.minutes.from_now,
                                 postponable_for: booking.organisation.short_deadline,
                                 remarks: booking.state)
      end

      after_transition(to: %i[definitive_request]) do |booking|
        booking.lock_editable!
        booking.deadline&.clear
      end

      after_transition(to: %i[open_request]) do |booking|
        booking.deadline&.clear
        booking.notifications.new(from_template: :manage_new_booking_mail, addressed_to: :manager).deliver
        if booking.agent_booking?
          # booking.notifications.new(from_template: :open_booking_agent_request,
          # addressed_to: :booking_agent).deliver
        else
          booking.notifications.new(from_template: :open_request, addressed_to: :tenant).deliver
        end
      end

      after_transition(to: %i[overdue_request overdue]) do |booking, transition|
        booking.notifications.new(from_template: transition.to_state.to_s, addressed_to: :tenant)&.deliver
      end

      after_transition(to: %i[booking_agent_request]) do |booking|
        booking.notifications.new(from_template: :booking_agent_request,
                                  addressed_to: :booking_agent).deliver
        booking.occupancy.tentative!
      end

      after_transition(to: %i[provisional_request definitive_request]) do |booking, transition|
        booking.notifications.new(from_template: transition.to_state.to_s, addressed_to: :tenant).deliver
        booking.occupancy.tentative!
        booking.lock_timeframe!
      end

      before_transition(to: %i[cancelled cancelled_request declined_request]) do |booking|
        booking.lock_editable!
        booking.occupancy.free!
      end

      after_transition(to: %i[cancelation_pending cancelled_request declined_request]) do |booking|
        booking.deadline&.clear
        booking.lock_timeframe!
      end

      # after_transition(to: :cancelation_pending) do |booking|
      # end

      after_transition(to: %i[awaiting_contract upcoming active overdue]) do |booking|
        booking.occupancy.occupied!
      end

      after_transition(to: %i[upcoming]) do |booking|
        booking.notifications.new(from_template: :upcoming, addressed_to: :tenant).deliver
      end

      after_transition(to: %i[upcoming_soon]) do |booking|
        booking.notifications.new(from_template: :upcoming_soon, addressed_to: :tenant)&.deliver
      end

      after_transition(to: %i[payment_due]) do |booking|
        invoice = booking.invoices.sent.unpaid.order(payable_until: :asc).last
        payable_until = invoice&.payable_until || 30.days.from_now
        postponable_for = booking.organisation.short_deadline
        booking.deadline&.clear
        booking.deadlines.create(at: payable_until, postponable_for: postponable_for) unless booking.deadline
      end

      after_transition(to: %i[payment_overdue]) do |booking|
        booking.notifications.new(from_template: :payment_overdue, addressed_to: :tenant).deliver
      end

      after_transition(to: %i[awaiting_contract upcoming completed]) do |booking|
        booking.deadline&.clear
      end

      after_transition(to: %i[cancelled]) do |booking|
        booking.notifications.new(from_template: :cancelled, addressed_to: :tenant).deliver
        if booking.agent_booking?
          booking.notifications.new(from_template: :booking_agent_cancelled, addressed_to: :booking_agent)
                 .deliver
        end
        booking.concluded!
      end

      after_transition(to: %i[completed], &:concluded!)

      after_transition(to: %i[cancelled_request]) do |booking|
        addressed_to = booking.agent_booking? ? :booking_agent : :tenant
        booking.notifications.new(from_template: :cancelled_request, addressed_to: addressed_to).deliver
        booking.concluded!
      end

      after_transition(to: %i[declined_request]) do |booking|
        addressed_to = booking.agent_booking? ? :booking_agent : :tenant
        booking.notifications.new(from_template: :declined_request, addressed_to: addressed_to).deliver
        booking.concluded!
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
