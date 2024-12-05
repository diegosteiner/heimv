# frozen_string_literal: true

module Accounting
  JournalEntry = Data.define(:id, :account, :date, :tax_code, :text, :amount, :side, :cost_center,
                             :index, :amount_type, :source, :reference, :currency, :booking) do
    extend ActiveModel::Translation
    extend ActiveModel::Naming

    def initialize(**args)
      args.symbolize_keys!
      defaults = { id: nil, index: nil, tax_code: nil, text: nil, cost_center: nil, source: nil }
      side = args.delete(:side) if %i[soll haben].include?(args[:side])
      date = args.delete(:date)&.then { _1.try(:to_date) || Date.parse(_1).to_date }
      super(**defaults, **args, side:, date:)
    end

    def soll?
      side == :soll
    end

    def haben?
      side == :haben
    end

    def soll_account
      account if soll?
    end

    def haben_account
      account if haben?
    end

    def valid?
      (soll_account.present? || haben_account.present?) && amount.present?
    end

    def to_s
      [
        (id || index).presence&.then { "[#{_1}]" },
        soll_account,
        '->',
        haben_account,
        ActiveSupport::NumberHelper.number_to_currency(amount, unit: currency),
        ':',
        text
      ].compact.join(' ')
    end
  end
end
