# frozen_string_literal: true

module Public
  module BookingParams
    class Update < ApplicationParams
      def self.permitted_keys
        [:tenant_organisation, :cancellation_reason, :invoice_address, :locale, :committed_request,
         :purpose_description, :booking_category_id, :approximate_headcount, :remarks, :begins_at, :ends_at,
         { tenant_attributes: TenantParams.permitted_keys.without(:email),
           deadlines_attributes: %i[id postpone],
           bookable_extra_ids: [], home_ids: [] }]
      end
    end

    class Create < Update
      def self.permitted_keys
        super + [:home_ids, :email, :accept_conditions, :email, :begins_at, :ends_at,
                 { agent_booking_attributes: %i[booking_agent_code booking_agent_ref] }]
      end
    end
  end
end
