# frozen_string_literal: true

module Manage
  class BookingParams < Public::BookingParams::Create
    def self.permitted_keys
      super +
        %i[tenant_id notifications_enabled internal_remarks transition_to
           cancellation_reason editable usage_report] +
        [occupancy_attributes: Manage::OccupancyParams.permitted_keys] +
        [usages_attributes: UsageParams.permitted_keys + %i[_destroy id]] +
        [tenant_attributes: TenantParams.permitted_keys] +
        [agent_booking_attributes: Public::AgentBookingParams.permitted_keys] +
        [deadline_attributes: %i[at postponable_for]]
    end
  end
end
