# frozen_string_literal: true

module BookingStates
  class OpenRequest < Base
    use_mail_template(:manage_new_booking_notification, context: %i[booking])
    use_mail_template(:open_booking_agent_request_notification, context: %i[booking])
    use_mail_template(:open_request_notification, context: %i[booking])

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :open_request
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.update(concluded: false)
      OperatorResponsibility.assign(booking, :administration, :billing)
      MailTemplate.use(:manage_new_booking_notification, booking, to: :administration, &:autodeliver!)

      if booking.agent_booking.present?
        MailTemplate.use(:open_booking_agent_request_notification, booking, to: :booking_agent, &:autodeliver!)
      else
        MailTemplate.use(:open_request_notification, booking, to: :tenant, &:autodeliver!)
      end
    end

    def relevant_time
      booking.created_at
    end
  end
end
