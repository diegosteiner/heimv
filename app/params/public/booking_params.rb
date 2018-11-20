# frozen_string_literal: true

module Public
  module BookingParams
    class Update < ApplicationParams
      def self.permitted_keys
        [:organisation, :cancellation_reason, :invoice_address,
         :committed_request, :purpose, :approximate_headcount, :remarks,
         tenant_attributes: TenantParams.permitted_keys.without(:email),
         deadlines_attributes: %i[id extend]]
      end
    end

    class Create < Update
      def self.sanitize(params)
        return params unless params[:occupancy_attributes]

        params.merge(occupancy_attributes: OccupancyParams.permit(params[:occupancy_attributes]))
      end

      def self.permitted_keys
        super + [:organisation, :home_id, :email, :booking_agent_code,
                 occupancy_attributes: OccupancyParams.permitted_keys]
      end
    end
  end
end
