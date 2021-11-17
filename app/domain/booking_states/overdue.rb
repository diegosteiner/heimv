# frozen_string_literal: true

module BookingStates
  class Overdue < Base
    RichTextTemplate.require_template(:overdue_notification, context: %i[booking], required_by: self, optional: true)

    include Rails.application.routes.url_helpers

    def checklist
      [
        deposits_paid_checklist_item, contract_signed_checklist_item
      ]
    end

    def self.to_sym
      :overdue
    end

    after_transition do |booking|
      booking.occupancy.occupied!
      booking.notifications.new(from_template: :overdue_notification, to: booking.tenant)&.deliver
    end

    infer_transition(to: :upcoming) do |booking|
      booking.contracts.signed.any? && Invoices::Deposit.of(booking).kept.all?(&:paid?)
    end

    def relevant_time
      booking.deadline&.at
    end

    protected

    def deposits_paid_checklist_item
      ChecklistItem.new(:deposit_paid, Invoices::Deposit.of(booking).kept.all?(&:paid?),
                        manage_booking_invoices_path(booking, org: booking.organisation.slug))
    end

    def contract_signed_checklist_item
      ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?,
                        manage_booking_contracts_path(booking, org: booking.organisation.slug))
    end
  end
end
