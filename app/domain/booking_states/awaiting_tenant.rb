# frozen_string_literal: true

module BookingStates
  class AwaitingTenant < Base
    RichTextTemplate.require_template(:awaiting_tenant_notification, context: %i[booking], required_by: self)
    RichTextTemplate.require_template(:booking_agent_request_accepted_notification, context: %i[booking],
                                                                                    required_by: self)

    def checklist
      []
    end

    def self.to_sym
      :awaiting_tenant
    end

    guard_transition do |booking|
      booking.agent_booking.present?
    end

    after_transition do |booking|
      booking.notifications.new(from_template: :awaiting_tenant_notification, to: booking.tenant).deliver
      booking.notifications.new(from_template: :booking_agent_request_accepted_notification,
                                to: booking.agent_booking.booking_agent).deliver
    end

    infer_transition(to: :overdue_request, &:deadline_exceeded?)
    infer_transition(to: :definitive_request) do |booking|
      booking.tenant.valid?(:public_update) && booking.committed_request
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
