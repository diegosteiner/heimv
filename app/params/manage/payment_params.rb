module Manage
  class PaymentParams < ApplicationParams
    def self.permitted_keys
      %i[amount invoice_id booking_id paid_at]
    end
  end
end
