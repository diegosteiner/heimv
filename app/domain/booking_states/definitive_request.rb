# frozen_string_literal: true

module BookingStates
  class DefinitiveRequest < Base
    templates << MailTemplate.define(:definitive_request_notification, context: %i[booking])
    templates << MailTemplate.define(:manage_definitive_request_notification, context: %i[booking], optional: true)
    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:responsibilities_assigned, :tarifs_chosen, :deposit_created,
                                        :contract_created, booking:)
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :definitive_request
    end

    guard_transition do |booking|
      booking.tenant&.valid?
    end

    infer_transition(to: :upcoming) do |booking|
      booking.contracts.sent.none? && booking.tenant&.bookings_without_contract
    end

    infer_transition(to: :awaiting_contract) do |booking|
      booking.contracts.sent.any?
    end

    after_transition do |booking|
      if occupied_occupancy_state?(booking)
        booking.occupied!
      elsif !booking.occupied?
        booking.tentative!
      end
    end

    after_transition do |booking|
      booking.update!(committed_request: true)
      booking.deadline&.clear
      OperatorResponsibility.assign(booking, :home_handover, :home_return)
      MailTemplate.use(:manage_definitive_request_notification, booking, to: :administration, &:autodeliver!)
      mail = MailTemplate.use(:definitive_request_notification, booking, to: :tenant)
      mail&.autodeliver!
    end

    def relevant_time
      booking.created_at
    end
  end
end
