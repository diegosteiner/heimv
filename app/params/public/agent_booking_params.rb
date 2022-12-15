# frozen_string_literal: true

module Public
  class AgentBookingParams < ApplicationParams
    def self.permitted_keys
      [:booking_agent_code, :booking_agent_ref, :tenant_email,
       { booking_attributes: %i[begins_at ends_at home_ids] }]
    end
  end
end
