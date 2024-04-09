# frozen_string_literal: true

module Manage
  class BookingParams < Public::BookingParams::Create
    define do
      optional(:tenant_id).filled(:integer)
      optional(:notifications_enabled).filled(:bool)
      optional(:internal_remarks).maybe(:string)
      optional(:transition_to).maybe(:string)
      optional(:cancellation_reason).maybe(:string)
      optional(:editable).filled(:bool)
      optional(:usage_report).maybe(:string)
      optional(:occupancy_color).maybe(:string)
      optional(:ignore_conflicting).filled(:bool)

      optional(:tenant_attributes).hash(TenantParams.new)
      optional(:agent_booking_attributes).hash(Public::AgentBookingParams.new)
      # optional(:booking_question_responses_attributes).array(Public::BookingQuestionResponseParams)
      optional(:usages_attributes).hash(UsageParams.new) do
        required(:id).filled(:integer)
        optional(:_destroy).filled(:bool)
      end

      optional(:deadline_attributes).hash do
        required(:at).filled(:date_time)
        optional(:postponable_for).maybe(:integer)
      end
    end
  end
end
