# frozen_string_literal: true

module BookingStates
  class PaymentDue < Base
    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:invoices_settled, booking:)
    end

    def self.to_sym
      :payment_due
    end

    after_transition do |booking|
      booking.deadline&.clear!
      outstanding_invoices = booking.invoices.kept.sent.outstanding.ordered
      payable_until = outstanding_invoices.filter_map(&:payable_until).max
      next if payable_until.blank?

      booking.create_deadline(at: payable_until + booking.organisation.deadline_settings.payment_overdue_deadline,
                              postponable_for: booking.organisation.deadline_settings.deadline_postponable_for,
                              armed: true)
    end

    infer_transition(to: :completed) do |booking|
      !booking.invoices.kept.sent.unsettled.exists?
    end

    infer_transition(to: :payment_overdue) do |booking|
      booking.invoices.kept.sent.outstanding.overdue.exists?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
