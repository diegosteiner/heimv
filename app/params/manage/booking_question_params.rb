# frozen_string_literal: true

module Manage
  class BookingQuestionParams < ApplicationParams
    def self.permitted_keys
      %i[type label description ordinal_position key required tenant_mode booking_agent_mode applying_conditions] +
        I18n.available_locales.map { |locale| ["label_#{locale}", "description_#{locale}"] }.flatten +
        [{ options: [] }]
    end
  end
end
