# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class AwaitingTenant < BookingStrategy::State
        Default.require_markdown_template(:awaiting_tenant_notification, %i[booking])
        Default.require_markdown_template(:booking_agent_request_accepted_notification, %i[booking])

        def checklist
          []
        end

        def self.to_sym
          :awaiting_tenant
        end

        def self.successors
          %i[definitive_request overdue_request cancelled_request declined_request overdue_request]
        end

        guard_transition do |booking|
          booking.agent_booking.present?
        end

        after_transition do |booking|
          booking.notifications.new(from_template: :awaiting_tenant_notification, addressed_to: :tenant).deliver
          booking.notifications.new(from_template: :booking_agent_request_accepted_notification,
                                    addressed_to: :booking_agent).deliver
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
  end
end
