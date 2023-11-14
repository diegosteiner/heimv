# frozen_string_literal: true

module BookingStates
  class CancelationPending < Base
    templates << MailTemplate.define(:operator_cancellation_pending_notification, context: %i[booking], optional: true)
    def checklist
      []
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :cancelation_pending
    end

    def self.successors
      %i[cancelled overdue]
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.update!(editable: false)
      MailTemplate.use(:operator_cancellation_pending_notification, booking, to: :home_handover, &:deliver)
      MailTemplate.use(:operator_cancellation_pending_notification, booking, to: :home_return, &:deliver)
    end

    infer_transition(to: :cancelled) do |booking|
      !booking.invoices.kept.unsettled.exists?
    end

    def relevant_time; end
  end
end
