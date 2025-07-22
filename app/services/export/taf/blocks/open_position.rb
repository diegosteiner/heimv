# frozen_string_literal: true

module Export
  module Taf
    module Blocks
      class OpenPosition < Block
        def initialize(**properties, &)
          super(:OPd, **properties, &)
        end

        def self.build_with_invoice(invoice, **override)
          op_id = override[:OpId].presence || Value.cast(invoice.ref, as: :symbol)
          pk_key = override[:PkKey].presence || Value.cast(invoice.booking.tenant.ref, as: :symbol)

          new(PkKey: pk_key, OpId: op_id, ZabId: '15T', Ref: invoice.payment_ref,
              Text: JournalEntryBatches::Invoice.invoice_text(invoice), **override)
        end
      end
    end
  end
end
