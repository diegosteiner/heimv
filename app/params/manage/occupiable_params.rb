# frozen_string_literal: true

module Manage
  class OccupiableParams < ApplicationParams
    def self.permitted_keys
      %i[name description active occupiable type ref home_id ordinal] +
        [{ settings: %i[booking_margin] }]
    end
  end
end
