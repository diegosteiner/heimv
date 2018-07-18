module Manage
  class InvoiceParams < ApplicationParams
    def self.permitted_keys
      %i[invoice_type text issued_at payable_until esr_number] +
        [{ invoice_parts_attributes: InvoicePartParams.permitted_keys + %i[id apply]}]
    end
  end
end
