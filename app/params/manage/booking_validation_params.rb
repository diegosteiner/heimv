# frozen_string_literal: true

module Manage
  class BookingValidationParams < ApplicationParams
    def self.permitted_keys
      %i[ordinal_position] +
        I18n.available_locales.map { |locale| ["error_message_#{locale}"] }.flatten +
        [{
          check_on: [],
          enabling_conditions_attributes: BookingConditionParams.permitted_keys + %i[id _destroy],
          validating_conditions_attributes: BookingConditionParams.permitted_keys + %i[id _destroy]
        }]
    end
  end
end
