# frozen_string_literal: true

module Manage
  class OccupiableParams < ApplicationParams
    def self.permitted_keys
      %i[name description active occupiable_id type ref]
    end
  end
end
