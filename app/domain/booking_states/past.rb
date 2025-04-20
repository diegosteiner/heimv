# frozen_string_literal: true

module BookingStates
  class Past < Base
    use_mail_template(:past_notification, context: %i[booking], optional: true)
    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:usages_entered, :invoice_created, booking:)
    end

    def self.to_sym
      :past
    end

    after_transition do |booking|
      OperatorResponsibility.assign(booking, :administration, :billing)
      MailTemplate.use(:past_notification, booking, to: :tenant, &:autodeliver!)
    end

    infer_transition(to: :payment_due) do |booking|
      Invoices::Invoice.of(booking).kept.any?(&:sent?)
    end

    infer_transition(to: :completed) do |booking|
      booking.tenant.bookings_without_invoice
    end

    def relevant_time
      booking.ends_at
    end
  end
end
