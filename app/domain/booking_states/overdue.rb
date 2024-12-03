# frozen_string_literal: true

module BookingStates
  class Overdue < Base
    templates << MailTemplate.define(:overdue_notification, context: %i[booking], optional: true)

    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:deposit_paid, :contract_signed, booking:)
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :overdue
    end

    after_transition do |booking|
      booking.deadline&.clear
      MailTemplate.use(:overdue_notification, booking, to: :tenant, &:autodeliver!)
    end

    infer_transition(to: :upcoming) do |booking|
      booking.contracts.signed.any? && Invoices::Deposit.of(booking).kept.all?(&:paid?)
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
