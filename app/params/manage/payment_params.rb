module Manage
  class PaymentParams < ApplicationParams
    def self.permitted_keys
      %i[amount invoice_id booking_id paid_at ref]
    end
  end
end
