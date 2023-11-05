# frozen_string_literal: true

module BookingStates
  class OpenRequest < Base
    RichTextTemplate.require_template(:manage_new_booking_notification, template_context: %i[booking],
                                                                        required_by: self)
    RichTextTemplate.require_template(:open_request_notification, template_context: %i[booking], required_by: self)

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
      OperatorResponsibility.assign(booking, :administration, :billing)
      to = booking.responsibilities[:administration] || booking.organisation
      booking.notifications.new(template: :manage_new_booking_notification, to:)&.deliver
      if booking.agent_booking.present?
        # booking.notifications.new(template:  :open_booking_agent_request_notification,
        # to: booking.agent_booking.booking_agent).deliver
      else
        booking.notifications.new(template: :open_request_notification, to: booking.tenant)&.deliver
      end
    end

    # infer_transition(from: :open_request, to: :provisional_request) do |booking|
    #   !booking.tenant&.reservations_allowed
    # end

    def relevant_time
      booking.created_at
    end
  end
end
