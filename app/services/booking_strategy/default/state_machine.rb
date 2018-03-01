module BookingStrategy
  module Default
    class StateMachine < Base::StateMachine
      state :initial, initial: true
      %i[
        new_request provisional_request definitive_request overdue_request cancelled
        confirmed upcoming overdue active past payment_due payment_overdue completed
      ].each { |s| state(s) }

      PREFERED_TRANSITIONS = {
        initial: :new_request,
        new_request: :provisional_request,
        provisional_request: :definitive_request,
        definitive_request: :confirmed,
        overdue_request: :confirmed,
        confirmed: :upcoming,
        overdue: :upcoming,
        upcoming: :active,
        active: :past,
        past: :payment_due,
        payment_due: :completed,
        payment_overdue: :completed
      }.with_indifferent_access.freeze

      transition from: :initial, to: %i[new_request provisional_request definitive_request]
      transition from: :overdue_request, to: %i[cancelled definitive_request provisional_request]
      transition from: :new_request, to: %i[cancelled provisional_request definitive_request]
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
      # booking.errors.add(:kind, I18n.t('errors.messages.blank')) if booking.event_kind.blank?
      # if booking.approximate_headcount.blank?
      #   booking.errors.add(:approximate_headcount, I18n.t('errors.messages.blank'))
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
        BookingNotificationService.new(booking).confirm_request_notification
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

      automatic_transition(to: :cancelled) do |booking|
        booking.cancellation_reason.present?
      end

      automatic_transition(from: :new_request, to: :provisional_request) do |booking|
        booking.valid? && !booking.committed_request.nil? && !booking.committed_request
      end

      automatic_transition(from: %i[new_request provisional_request], to: :definitive_request, &:committed_request)
    end
  end
end
