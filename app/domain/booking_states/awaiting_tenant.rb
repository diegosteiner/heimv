# frozen_string_literal: true

module BookingStates
  class AwaitingTenant < Base
    templates << MailTemplate.define(:awaiting_tenant_notification, context: %i[booking])
    templates << MailTemplate.define(:booking_agent_request_accepted_notification, context: %i[booking])

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :awaiting_tenant
    end

    guard_transition do |booking|
      booking.agent_booking.present? && booking.email.present?
    end

    after_transition do |booking|
      if occupied_occupancy_state?(booking)
        booking.occupied!
      elsif !booking.occupied?
        booking.tentative!
      end
    end

    after_transition do |booking|
      MailTemplate.use(:awaiting_tenant_notification, booking, to: :tenant, &:deliver)
      MailTemplate.use(:booking_agent_request_accepted_notification, booking, to: :booking_agent, &:deliver)
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.deadlines.create(length: booking.organisation.settings.provisional_request_deadline,
                               postponable_for: booking.organisation.settings.deadline_postponable_for,
                               remarks: booking.booking_state.t(:label))
    end

    infer_transition(to: :overdue_request) do |booking|
      booking.deadline_exceeded?
    end

    infer_transition(to: :definitive_request) do |booking|
      booking.tenant&.valid?(:public_update) && booking.committed_request
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
