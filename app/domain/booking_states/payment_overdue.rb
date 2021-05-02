# frozen_string_literal: true

module BookingStates
  class PaymentOverdue < Base
    RichTextTemplate.require_template(:payment_overdue_notification, context: %i[booking], required_by: self)

    include Rails.application.routes.url_helpers

    def self.to_sym
      :payment_overdue
    end

    def checklist
      [
        ChecklistItem.new(:invoice_paid, booking.invoices.kept.all?(&:paid),
                          manage_booking_invoices_path(booking, org: booking.organisation.slug))
      ]
    end

    after_transition do |booking|
      booking.notifications.new(from_template: :payment_overdue_notification, addressed_to: :tenant).deliver
    end

    infer_transition(to: :completed) do |booking|
      !booking.invoices.unpaid.kept.exists?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
