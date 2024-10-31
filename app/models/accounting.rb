# frozen_string_literal: true

module Accounting
  JournalEntry = Data.define(:date, :items) do
    def initialize(**args)
      defaults = { items: [] }
      super(defaults.merge(args))
    end
  end

  JournalEntryItem = Data.define(:account, :date, :tax_code, :text, :amount, :side, :cost_center,
                                 :index, :amount_type, :source) do
    delegate :invoice, to: :invoice_part

    def initialize(**args)
      defaults = { index: nil, tax_code: nil, text: '', cost_center:, source: nil }
      super(defaults.merge(args))
    end
  end
end
