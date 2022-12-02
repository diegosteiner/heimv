# frozen_string_literal: true

module Manage
  class BookingConditionParams < ApplicationParams
    def self.permitted_keys
      # TODO: check
      # %i[qualifiable_id qualifiable_type type must_condition distinction]
      %i[type must_condition distinction]
    end
  end
end
