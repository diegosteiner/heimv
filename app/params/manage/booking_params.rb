module Manage
  class BookingParams < Public::BookingParams::Create
    def self.permitted_keys
      super +
        %i[transition_to messages_enabled internal_remarks cancellation_reason] +
        [occupancy_attributes: Public::OccupancyParams.permitted_keys] +
        [usages_attributes: UsageParams.permitted_keys + %i[_destroy id]] +
        [tenant_attributes: TenantParams.permitted_keys] +
        [agent_booking_attributes: Public::AgentBookingParams.permitted_keys] +
        [deadline_attributes: %i[at postponable_for]]
    end

    sanitize do |params|
      next params if params[:occupancy_attributes].blank?

      params.merge(occupancy_attributes: Public::OccupancyParams.new(params[:occupancy_attributes]).sanitized)
    end
  end
end
