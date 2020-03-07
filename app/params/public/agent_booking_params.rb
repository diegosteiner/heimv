# frozen_string_literal: true

module Public
  class AgentBookingParams < ApplicationParams
    def self.permitted_keys
      [:booking_agent_code, :booking_agent_ref, :home_id, :tenant_email,
       occupancy_attributes: OccupancyParams.permitted_keys]
    end

    sanitize do |params|
      next params if params[:occupancy_attributes].blank?

      params.merge(occupancy_attributes: Public::OccupancyParams.new(params[:occupancy_attributes]).permitted)
    end
  end
end
