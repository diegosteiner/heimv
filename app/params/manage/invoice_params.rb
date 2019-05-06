module Manage
  class InvoiceParams < ApplicationParams
    def self.permitted_keys
      %i[invoice_type text booking_id issued_at sent_at payable_until ref print_payment_slip] +
        [{ invoice_parts_attributes: InvoicePartParams.permitted_keys + %i[id apply _destroy] }]
    end
  end
end
