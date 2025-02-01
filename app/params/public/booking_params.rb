# frozen_string_literal: true

module Public
  module BookingParams
    class Update < ApplicationParams
      def self.permitted_keys
        [:tenant_organisation, :cancellation_reason, :invoice_address, :locale, :committed_request,
         :purpose_description, :booking_category_id, :approximate_headcount, :remarks, :begins_at, :ends_at,
         { tenant_attributes: TenantParams.permitted_keys.without(:email), occupiable_ids: [],
           deadlines_attributes: %i[id postpone] }]
      end
    end

    class Create < Update
      def self.permitted_keys
        permitted_keys = super
        nested_keys = permitted_keys.extract_options!
        nested_keys[:agent_booking_attributes] = %i[booking_agent_code booking_agent_ref]
        permitted_keys + [:email, :accept_conditions, :home_id, nested_keys]
      end
    end
  end
end
