# frozen_string_literal: true

module Manage
  class InvoicePartParams < ApplicationParams
    def self.permitted_keys
      %i[usage_id label breakdown amount type ordinal_position vat]
    end
  end
end
