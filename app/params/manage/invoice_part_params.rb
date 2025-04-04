# frozen_string_literal: true

module Manage
  class InvoicePartParams < ApplicationParams
    def self.permitted_keys
      %i[usage_id label breakdown amount type ordinal_position vat_category_id
         accounting_account_nr accounting_cost_center_nr]
    end
  end
end
