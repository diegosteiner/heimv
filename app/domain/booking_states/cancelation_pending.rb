# frozen_string_literal: true

module BookingStates
  class CancelationPending < Base
    use_mail_template(:operator_cancelation_pending_notification, context: %i[booking], optional: true)
    use_mail_template(:manage_cancelation_pending_notification, context: %i[booking], optional: true)

    def checklist
      BookingStateChecklistItem.prepare(:invoices_settled, booking:)
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
      booking.free!
      booking.deadline&.clear!

      Notification.dedup(booking, to: %i[billing home_handover home_return]) do |to|
        MailTemplate.use(:operator_cancelation_pending_notification, booking, to:, &:autodeliver!)
      end
      MailTemplate.use(:manage_cancelation_pending_notification, booking, to: :administration, &:autodeliver!)
    end

    infer_transition(to: :cancelled) do |booking|
      !booking.invoices.kept.unsettled.exists?
    end

    def relevant_time; end
  end
end
