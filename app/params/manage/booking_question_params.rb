# frozen_string_literal: true

module Manage
  class BookingQuestionParams < ApplicationParams
    def self.permitted_keys
      %i[type label description ordinal_position key required tenant_mode booking_agent_mode] +
        I18n.available_locales.map { |locale| ["label_#{locale}", "description_#{locale}"] }.flatten +
        [{ applying_condition_attributes: BookingConditionParams.permitted_keys + %i[id _destroy],
           options: [] }]
    end
  end
end
