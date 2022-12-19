# frozen_string_literal: true

module BookingStates
  class UnconfirmedRequest < Base
    RichTextTemplate.require_template(:unconfirmed_request_notification, context: %i[booking], required_by: self)

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
      booking.deadline_exceeded?
    end
    infer_transition(to: :open_request) do |booking|
      booking.valid?(:public_update) || booking.agent_booking.present?
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.deadlines.create(length: booking.organisation.settings.unconfirmed_request_deadline,
                               remarks: booking.booking_state.t(:label))
      booking.tentative!
      booking.notifications.new(template: :unconfirmed_request_notification, to: booking.tenant).deliver
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
