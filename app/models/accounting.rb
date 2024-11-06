# frozen_string_literal: true

module Accounting
  JournalEntry = Data.define(:id, :date, :invoice_id, :items) do
    extend ActiveModel::Translation
    extend ActiveModel::Naming

    def initialize(**args)
      args.symbolize_keys!
      date = args.delete(:date)&.then { _1.try(:to_date) || Date.parse(_1).to_date }
      items = Array.wrap(args.delete(:items)).map do |item|
        case item
        when Hash, JournalEntryItem
          JournalEntryItem.new(**item.to_h.merge(journal_entry: self))
        end
      end.compact
      super(id: nil, **args, items:, date:)
    end

    def to_h
      super.merge(items: items.map(&:to_h))
    end
  end

  JournalEntryItem = Data.define(:id, :account, :date, :tax_code, :text, :amount, :side, :cost_center,
                                 :index, :amount_type, :source, :invoice_id) do
    extend ActiveModel::Translation
    extend ActiveModel::Naming

    def initialize(**args)
      args.symbolize_keys!
      @journal_entry = args.delete(:journal_entry)
      defaults = { id: nil, index: nil, tax_code: nil, text: '', cost_center: nil }
      date = args.delete(:date)&.then { _1.try(:to_date) || Date.parse(_1).to_date }
      super(**defaults, **args, date:)
    end
  end
end
