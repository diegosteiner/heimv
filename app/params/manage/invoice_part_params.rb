# frozen_string_literal: true

module Manage
  class InvoicePartParams < ApplicationParams
    def self.permitted_keys
      %i[usage_id label breakdown amount type position position_position]
    end
  end
end
