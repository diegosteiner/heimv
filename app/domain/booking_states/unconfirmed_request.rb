# frozen_string_literal: true

module BookingStates
  class UnconfirmedRequest < Base
    use_mail_template(:unconfirmed_request_notification, context: %i[booking])

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :unconfirmed_request
    end

    infer_transition(to: :declined_request) do |booking|
      booking.deadline&.exceeded?
    end
    infer_transition(to: :open_request) do |booking|
      booking.valid?(:public_update) || booking.agent_booking.present?
    end

    after_transition do |booking|
      booking.create_deadline(length: booking.organisation.deadline_settings.unconfirmed_request_deadline,
                              remarks: booking.booking_state.t(:label))
      booking.tentative!
      MailTemplate.use(:unconfirmed_request_notification, booking, to: :tenant, &:autodeliver!)
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
