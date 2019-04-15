# frozen_string_literal: true

module Public
  module BookingParams
    class Update < ApplicationParams
      def self.permitted_keys
        [:tenant_organisation, :cancellation_reason, :invoice_address, :email,
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
        super + [:tenant_organisation, :home_id, :email, :booking_agent_code, :booking_agent_ref,
                 :accept_conditions, occupancy_attributes: OccupancyParams.permitted_keys]
      end
    end
  end
end
