# frozen_string_literal: true

module BookingStates
  class PaymentOverdue < Base
    use_mail_template(:payment_overdue_notification, context: %i[booking invoices])

    include Rails.application.routes.url_helpers

    def self.to_sym
      :payment_overdue
    end

    def checklist
      []
    end

    after_transition do |booking|
      booking.deadline&.clear!

      invoices = booking.invoices.kept.unsettled
      MailTemplate.use(:payment_overdue_notification, booking, to: :tenant, context: { invoices: })&.tap do |mail|
        mail.attach(invoices)
        mail.autodeliver!
      end
    end

    infer_transition(to: :completed) do |booking|
      !booking.invoices.kept.unsettled.exists?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
