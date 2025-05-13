# frozen_string_literal: true

module Manage
  class BookingValidationParams < ApplicationParams
    def self.permitted_keys
      %i[ordinal_position enabling_conditions validating_conditions] +
        I18n.available_locales.map { |locale| ["error_message_#{locale}"] }.flatten +
        [{ check_on: [] }]
    end
  end
end
