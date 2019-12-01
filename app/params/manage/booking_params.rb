module Manage
  class BookingParams < Public::BookingParams::Create
    def self.permitted_keys
      super +
        %i[transition_to messages_enabled internal_remarks] +
        [usages_attributes: UsageParams.permitted_keys + %i[_destroy id]] +
        [tenant_attributes: TenantParams.permitted_keys]
    end

    sanitize do |params|
      next params if params[:occupancy_attributes].blank?

      params.merge(occupancy_attributes: Public::OccupancyParams.new(params[:occupancy_attributes]).permitted)
    end
  end
end
