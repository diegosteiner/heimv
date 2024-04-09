# frozen_string_literal: true

module Public
  class AgentBookingParams < ApplicationParamsSchema
    define do
      optional(:booking_agent_code).filled(:string)
      optional(:booking_agent_ref).filled(:string)
      optional(:tenant_email).filled(:string)
      optional(:booking_attributes).hash(BookingParams::Update.new)
    end
  end
end
