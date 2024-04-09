# frozen_string_literal: true

module Manage
  class BookingConditionParams < ApplicationParamsSchema
    define do
      required(:qualifiable_id).filled(:integer)
      required(:qualifiable_type).filled(:string)
      required(:type).filled(:string)
      required(:must_condition).filled(:bool)
      required(:compare_value).maybe(:string)
      required(:compare_operator).maybe(:string)
      required(:compare_attribute).maybe(:string)
    end
  end
end
