# frozen_string_literal: true

module Accounting
  JournalEntryGroup = Data.define(:id, :date, :items) do
    extend ActiveModel::Translation
    extend ActiveModel::Naming

    def initialize(**args)
      args.symbolize_keys!
      date = args.delete(:date)&.then { _1.try(:to_date) || Date.parse(_1).to_date }
      items = Array.wrap(args.delete(:items)).map do |item|
        case item
        when Hash, JournalEntry
          JournalEntry.new(**item.to_h, journal_entry: self)
        end
      end.compact
      super(id: nil, **args, items:, date:)
    end

    def to_h
      super.merge(items: items.map(&:to_h))
    end
  end

  JournalEntry = Data.define(:id, :account, :date, :tax_code, :text, :amount, :side, :cost_center,
                             :index, :amount_type, :source) do
    extend ActiveModel::Translation
    extend ActiveModel::Naming

    def initialize(**args)
      args.symbolize_keys!
      @journal_entry = args.delete(:journal_entry)
      defaults = { id: nil, index: nil, tax_code: nil, text: nil, cost_center: nil, source: nil }
      date = args.delete(:date)&.then { _1.try(:to_date) || Date.parse(_1).to_date }
      super(**defaults, **args, date:)
    end
  end
end
