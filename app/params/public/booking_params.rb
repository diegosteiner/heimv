# frozen_string_literal: true

module Public
  module BookingParams
    class Update < ApplicationParams
      def self.permitted_keys
        [:tenant_organisation, :cancellation_reason, :invoice_address, :email, :locale,
         :committed_request, :purpose_id, :approximate_headcount, :remarks,
         { tenant_attributes: TenantParams.permitted_keys.without(:email),
           deadlines_attributes: %i[id postpone],
           occupancy_attributes: OccupancyParams.permitted_keys }]
      end

      sanitize do |params|
        next if params[:occupancy_attributes].blank?

        params.merge(occupancy_attributes: OccupancyParams.new(params[:occupancy_attributes]).permitted)
      end
    end

    class Create < Update
      def self.permitted_keys
        super + [:home_id, :email, :accept_conditions,
                 { agent_booking_attributes: %i[booking_agent_code booking_agent_ref] }]
      end

      sanitize do |params|
        next if params[:occupancy_attributes].blank?

        params.merge(occupancy_attributes: OccupancyParams.new(params[:occupancy_attributes]).permitted)
      end
    end
  end
end
