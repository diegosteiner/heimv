# frozen_string_literal: true

module Manage
  class PaymentParams < ApplicationParams
    def self.permitted_keys
      %i[amount invoice_id booking_id paid_at ref data remarks applies confirm write_off camt_instr_id
         accounting_account_nr accounting_cost_center_nr]
    end
  end
end
