  module Manage
    class InvoiceParams < ApplicationParams
      def self.permitted_keys
        %i[invoice_type text issued_at payable_until esr_number]
      end
    end
  end
