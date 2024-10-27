# frozen_string_literal: true

module Accounting
  class Factory
    def initialize(invoice)
      @invoice = invoice
    end

    def call; end
  end

  JournalEntry = Data.define(:account_id, :b_type, :cost_account_id, :cost_index, :code, :date,
                             :flags, :tax_id, :text, :tax_index, :type, :amount_netto, :amount_brutto, :amount_tax,
                             :op_id, :pk_id) do
    def initialize(**args)
      defaults = members.index_with(nil).merge({})
      super(defaults.merge(args))
    end
  end
end
