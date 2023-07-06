# frozen_string_literal: true

module Manage
  class BookingParams < Public::BookingParams::Create
    def self.permitted_keys
      permitted_keys = super
      nested_keys = permitted_keys.extract_options!
      permitted_keys + %i[tenant_id notifications_enabled internal_remarks transition_to
                          cancellation_reason editable usage_report occupancy_color ignore_conflicting] +
        [nested_keys.merge(usages_attributes: UsageParams.permitted_keys + %i[_destroy id],
                           tenant_attributes: TenantParams.permitted_keys,
                           agent_booking_attributes: Public::AgentBookingParams.permitted_keys,
                           deadline_attributes: %i[at postponable_for],
                           booking_question_responses_attributes: [:booking_question_id, { value: {} }])]
    end
  end
end
