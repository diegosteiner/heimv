# frozen_string_literal: true

module BookingStates
  class Past < Base
    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:usages_entered, :invoice_created, booking:)
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :past
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
