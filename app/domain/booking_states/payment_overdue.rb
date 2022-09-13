# frozen_string_literal: true

module BookingStates
  class PaymentOverdue < Base
    RichTextTemplate.require_template(:payment_overdue_notification, context: %i[booking], required_by: self)

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
      booking.notifications.new(template: :payment_overdue_notification, to: booking.tenant).deliver
    end

    infer_transition(to: :completed) do |booking|
      !booking.invoices.open.kept.exists?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
