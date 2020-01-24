# frozen_string_literal: true

module Public
  module BookingParams
    class Update < ApplicationParams
      def self.permitted_keys
        [:tenant_organisation, :cancellation_reason, :invoice_address, :email,
         :committed_request, :purpose, :approximate_headcount, :remarks,
         tenant_attributes: TenantParams.permitted_keys.without(:email),
         deadlines_attributes: %i[id postpone]]
      end
    end

    class Create < Update
      sanitize do |params|
        next params if params[:occupancy_attributes].blank?

        params.merge(occupancy_attributes: OccupancyParams.new(params[:occupancy_attributes]).permitted)
      end

      def self.permitted_keys
        super + [:tenant_organisation, :home_id, :email, :accept_conditions,
                 agent_booking_attributes: %i[booking_agent_code booking_agent_ref],
                 occupancy_attributes: OccupancyParams.permitted_keys]
      end
    end
  end
end
