# frozen_string_literal: true

module Manage
  class TarifParams < ApplicationParamsSchema
    define do
      optional(:type).filled(:string)
      # optional(:label).filled(:string)
      optional(:unit).maybe(:string)
      optional(:price_per_unit).maybe(:decimal)
      optional(:ordinal).maybe(:string)
      optional(:tarif_group).maybe(:string)
      optional(:accountancy_account).maybe(:string)
      optional(:pin).filled(:bool)
      optional(:prefill_usage_method).maybe(:string)
      optional(:prefill_usage_booking_question_id).maybe(:integer)
      optional(:minimum_usage_per_night).maybe(:decimal)
      optional(:minimum_usage_total).maybe(:decimal)
      optional(:vat).maybe(:decimal)
      optional(:associated_types).array(:string)

      optional(:selecting_conditions_attributes).hash(Manage::BookingConditionParams.new) do
        required(:id).filled(:integer)
        optional(:_destroy).filled(:bool)
      end

      optional(:enabling_conditions_attributes).hash(Manage::BookingConditionParams.new) do
        required(:id).filled(:integer)
        optional(:_destroy).filled(:bool)
      end

      I18n.available_locales.map do |locale|
        optional(:"label_#{locale}").maybe(:string)
        optional(:"unit_#{locale}").maybe(:string)
      end
    end
  end
end
