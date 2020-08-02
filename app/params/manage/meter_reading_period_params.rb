# frozen_string_literal: true

module Manage
  class MeterReadingPeriodParams < ApplicationParams
    def self.permitted_keys
      %i[start_value end_value]
    end
  end
end
