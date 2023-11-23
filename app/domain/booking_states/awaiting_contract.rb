# frozen_string_literal: true

module BookingStates
  class AwaitingContract < Base
    include Rails.application.routes.url_helpers

    def checklist
      [
        deposits_paid_checklist_item, contract_signed_checklist_item
      ]
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :awaiting_contract
    end

    guard_transition do |booking|
      booking.valid?
    end

    after_transition do |booking|
      if occupied_occupancy_state?(booking)
        booking.occupied!
      elsif !booking.occupied?
        booking.tentative!
      end
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.deadlines.create(length: booking.organisation.settings.awaiting_contract_deadline,
                               postponable_for: booking.organisation.settings.deadline_postponable_for,
                               remarks: booking.booking_state.t(:label))
    end

    infer_transition(to: :overdue) do |booking|
      booking.deadline_exceeded?
    end

    infer_transition(to: :upcoming) do |booking|
      booking.contracts.signed.any? &&
        Invoices::Deposit.of(booking).kept.all? do |deposit|
          deposit.paid? || deposit.payment_info.is_a?(PaymentInfos::OnArrival)
        end
    end

    def relevant_time
      booking.deadline&.at
    end

    protected

    def deposits_paid_checklist_item
      ChecklistItem.new(:deposit_paid, Invoices::Deposit.of(booking).kept.all?(&:paid?),
                        manage_booking_invoices_path(booking, org: booking.organisation, locale: I18n.locale))
    end

    def contract_signed_checklist_item
      ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?,
                        manage_booking_contracts_path(booking, org: booking.organisation, locale: I18n.locale))
    end
  end
end
