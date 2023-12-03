# frozen_string_literal: true

module BookingStates
  class PaymentOverdue < Base
    templates << MailTemplate.define(:payment_overdue_notification, context: %i[booking])

    include Rails.application.routes.url_helpers

    def self.to_sym
      :payment_overdue
    end

    def checklist
      []
    end

    def invoice_type
      Invoices::LateNotice
    end

    after_transition do |booking|
      MailTemplate.use(:payment_overdue_notification, booking, to: :tenant, &:autodeliver)
    end

    infer_transition(to: :completed) do |booking|
      !booking.invoices.kept.unsettled.exists?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
