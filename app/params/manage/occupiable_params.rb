# frozen_string_literal: true

module Manage
  class OccupiableParams < ApplicationParams
    def self.permitted_keys
      %i[name description active occupiable type ref home_id ordinal_position] +
        I18n.available_locales.map { |locale| ["name_#{locale}", "description_#{locale}"] }.flatten +
        [{ settings: %i[booking_margin] }]
    end
  end
end
