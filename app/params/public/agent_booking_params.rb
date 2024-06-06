# frozen_string_literal: true

module Public
  class AgentBookingParams < ApplicationParams
    def self.permitted_keys
      [:booking_agent_code, :booking_agent_ref, :tenant_email, :tenant_infos,
       { booking_attributes: %i[begins_at ends_at home_id tenant_organisation approximate_headcount
                                purpose_description remarks booking_category_id] +
         [{ occupiable_ids: [] }] }]
    end
  end
end
