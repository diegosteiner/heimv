# frozen_string_literal: true

module Public
  module BookingParams
    class Update < ApplicationParamsSchema
      define do
        optional(:tenant_organisation).maybe(:string)
        optional(:cancellation_reason).maybe(:string)
        optional(:invoice_address).maybe(:string)
        optional(:locale).maybe(:string)
        optional(:committed_request).maybe(:bool)
        optional(:purpose_description).maybe(:string)
        optional(:booking_category_id).maybe(:integer)
        optional(:approximate_headcount).maybe(:integer)
        optional(:remarks).maybe(:string)
        optional(:begins_at).maybe(:date_time)
        optional(:ends_at).maybe(:date_time)

        optional(:tenant_attributes).hash(TenantParams::Update.new)
        optional(:occupiable_ids).array(:integer)
        optional(:deadlines_attributes).schema do
          required(:id).filled(:integer)
          optional(:postpone).maybe(:bool)
        end
      end
    end

    class Create < Update
      define do
        optional(:agent_booking_attributes).hash do
          optional(:booking_agent_code).maybe(:string)
          optional(:booking_agent_ref).maybe(:string)
        end
        required(:email).filled(:string)
        optional(:home_id).filled(:integer)
        optional(:accept_conditions).maybe(:bool)
      end
    end
  end
end
