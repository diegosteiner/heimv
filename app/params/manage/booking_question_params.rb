# frozen_string_literal: true

module Manage
  class BookingQuestionParams < ApplicationParamsSchema
    define do
      optional(:type).filled(:string)
      optional(:label).filled(:string)
      optional(:description).maybe(:string)
      optional(:ordinal_position).maybe(:string)
      optional(:key).maybe(:string)
      optional(:required).filled(:bool)
      optional(:mode).filled(:string)
      optional(:applying_conditions_attributes).hash(BookingConditionParams.new) do
        required(:id).filled(:integer)
        optional(:_destroy).filled(:bool)
      end

      I18n.available_locales.map do |locale|
        optional(:"label_#{locale}").maybe(:string)
        optional(:"description_#{locale}").maybe(:string)
      end
    end
  end
end
