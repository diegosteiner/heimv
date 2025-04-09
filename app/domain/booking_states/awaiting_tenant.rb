# frozen_string_literal: true

module BookingStates
  class AwaitingTenant < Base
    use_mail_template(:awaiting_tenant_notification, context: %i[booking])
    use_mail_template(:booking_agent_request_accepted_notification, context: %i[booking])

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
      booking.email.present?
    end

    after_transition do |booking|
      if occupied_booking_state?(booking)
        booking.occupied!
      elsif !booking.occupied?
        booking.tentative!
      end
    end

    after_transition do |booking|
      booking.create_deadline(length: booking.organisation.deadline_settings.awaiting_tenant_deadline,
                              postponable_for: booking.organisation.deadline_settings.deadline_postponable_for,
                              remarks: booking.booking_state.t(:label))
      MailTemplate.use!(:awaiting_tenant_notification, booking, to: :tenant, &:autodeliver!)
      next if booking.agent_booking.blank?

      MailTemplate.use(:booking_agent_request_accepted_notification, booking, to: :booking_agent, &:autodeliver!)
    end

    infer_transition(to: :overdue_request) do |booking|
      booking.deadline&.exceeded?
    end

    infer_transition(to: :definitive_request) do |booking|
      booking.committed_request && booking.valid?(:public_update)
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
