module Manage
  class PaymentParams < ApplicationParams
    def self.permitted_keys
      %i[amount invoice_id booking_id paid_at ref data remarks applies write_off]
    end
  end
end
