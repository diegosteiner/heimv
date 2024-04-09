# frozen_string_literal: true

module Manage
  class OccupiableParams < ApplicationParamsSchema
    define do
      optional(:name).filled(:string)
      optional(:description).maybe(:string)
      optional(:active).filled(:bool)
      optional(:occupiable).filled(:bool)
      optional(:type).filled(:string)
      optional(:ref).filled(:string)
      optional(:home_id).maybe(:integer)
      optional(:ordinal_position).maybe(:string)
      optional(:settings).hash do
        required(:booking_margin).maybe(:string)
      end

      I18n.available_locales.map do |locale|
        optional(:"name_#{locale}").maybe(:string)
        optional(:"description_#{locale}").maybe(:string)
      end
    end
  end
end
