# frozen_string_literal: true

module Manage
  class BookingConditionSerializer < ApplicationSerializer
    IF_EXISTS_PROC = ->(field_name, condition, _options) { condition.respond_to?(field_name) }

    identifier :id

    association :conditions, blueprint: Manage::BookingConditionSerializer, if: IF_EXISTS_PROC

    field :type
    field :compare_operator, if: IF_EXISTS_PROC
    field :compare_value, if: IF_EXISTS_PROC
    field :compare_attribute, if: IF_EXISTS_PROC
    field :qualifiable_id do |booking_condition|
      booking_condition.qualifiable&.id
    end

    field :qualifiable_type do |booking_condition|
      booking_condition.qualifiable&.class&.name
    end

    view :with_errors do
      include_view :default
      field :errors
    end
  end
end
