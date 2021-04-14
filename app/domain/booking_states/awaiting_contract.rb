# frozen_string_literal: true

module BookingStates
  class AwaitingContract < Base
    include Rails.application.routes.url_helpers

    def checklist
      [
        deposits_paid_checklist_item, contract_signed_checklist_item
      ]
    end

    def self.to_sym
      :awaiting_contract
    end

    guard_transition do |booking|
      booking.occupancy.conflicting.none?
    end

    after_transition do |booking|
      booking.occupancy.occupied!
      booking.deadline&.clear
      booking.deadlines.create(at: booking.organisation.long_deadline.from_now,
                               postponable_for: booking.organisation.short_deadline,
                               remarks: booking.state)
    end

    infer_transition(to: :overdue, &:deadline_exceeded?)
    infer_transition(to: :upcoming) do |booking|
      booking.contracts.signed.any? && Invoices::Deposit.of(booking).kept.all?(&:paid)
    end

    def relevant_time
      booking.deadline&.at
    end

    protected

    def deposits_paid_checklist_item
      ChecklistItem.new(:deposit_paid, Invoices::Deposit.of(booking).kept.all?(&:paid),
                        manage_booking_invoices_path(booking, org: booking.organisation.slug))
    end

    def contract_signed_checklist_item
      ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?,
                        manage_booking_contracts_path(booking, org: booking.organisation.slug))
    end
  end
end
