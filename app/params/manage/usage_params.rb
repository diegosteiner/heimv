# frozen_string_literal: true

module Manage
  class UsageParams < ApplicationParamsSchema
    define do
      optional(:tarif_id).filled(:integer)
      optional(:booking_id).filled(:string)
      optional(:used_units).filled(:decimal)
      optional(:remarks).filled(:string)
      optional(:price_per_unit).filled(:decimal)
      optional(:committed).filled(:bool)
      optional(:meter_reading_period_attributes).hash do
        optional(:start_value).maybe(:decimal)
        optional(:end_value).maybe(:decimal)
        required(:id).filled(:integer)
        optional(:_destroy).filled(:bool)
      end
    end
  end
end
