# frozen_string_literal: true

module BookingStates
  class OverdueRequest < Base
    use_mail_template(:overdue_request_notification, context: %i[booking invoices], optional: true)

    def checklist
      []
    end

    def self.to_sym
      :overdue_request
    end

    after_transition do |booking|
      booking.deadline&.clear!
      length = booking.organisation.deadline_settings.overdue_request_deadline
      booking.create_deadline(length:, remarks: booking.booking_state.t(:label)) unless length.negative?

      invoices = booking.invoices.kept.outstanding
      MailTemplate.use(:overdue_request_notification, booking, to: :tenant, context: { invoices: })&.tap do |mail|
        mail.attach(invoices)
        mail.autodeliver!
      end
    end

    infer_transition(to: :definitive_request) do |booking|
      booking.committed_request && (booking&.tenant&.valid?(:public_update) || !booking.agent_booking)
    end

    infer_transition(to: :declined_request) do |booking|
      booking.deadline&.exceeded? && !booking.agent_booking
    end

    infer_transition(to: :awaiting_tenant) do |booking|
      booking.agent_booking&.valid? && booking.committed_request
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
