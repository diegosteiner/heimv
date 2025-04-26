# frozen_string_literal: true

module BookingStates
  class AwaitingContract < Base
    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:deposit_paid, :contract_signed, booking:)
    end

    def self.to_sym
      :awaiting_contract
    end

    guard_transition do |booking|
      booking.valid?
    end

    after_transition do |booking|
      if occupied_booking_state?(booking)
        booking.occupied!
      elsif !booking.occupied?
        booking.tentative!
      end
    end

    after_transition do |booking|
      booking.create_deadline(length: booking.organisation.deadline_settings.awaiting_contract_deadline,
                              postponable_for: booking.organisation.deadline_settings.deadline_postponable_for,
                              remarks: booking.booking_state.t(:label))
    end

    infer_transition(to: :overdue) do |booking|
      booking.deadline&.exceeded?
    end

    infer_transition(to: :upcoming) do |booking|
      booking.contracts.signed.any? &&
        Invoices::Deposit.of(booking).kept.all? do |deposit|
          deposit.paid? || !deposit.payment_required
        end
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
