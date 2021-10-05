# frozen_string_literal: true

module Manage
  class BookingOperatorParams < ApplicationParams
    def self.permitted_keys
      %i[responsibility operator_id]
    end
  end
end
