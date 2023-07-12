# frozen_string_literal: true

module Manage
  class BookingConditionParams < ApplicationParams
    def self.permitted_keys
      # TODO: check
      # %i[qualifiable_id qualifiable_type type must_condition compare_value]
      %i[type must_condition compare_value compare_operator compare_attribute]
    end
  end
end
