# frozen_string_literal: true

class JournalEntryBatch
  class Entry
    include StoreModel::Model

    attribute :amount, :decimal
    attribute :soll_account, :string
    attribute :haben_account, :string
    attribute :text, :string
    attribute :invoice_part_id, :integer
    attribute :vat_category_id, :integer
    attribute :vat_amount, :decimal
    attribute :cost_center

    enum :book_type, { main: 0, cost: 1, vat: 2 }, _prefix: true, default: :main # rubocop:disable Rails/EnumSyntax

    validates :soll_account, :haben_account, :amount, :book_type, presence: true
    validates :amount, numericality: { other_than: 0 }

    def journal_entry_batch
      parent
    end

    def to_h
      attributes.symbolize_keys
    end

    def to_s
      formatted_amount = ActiveSupport::NumberHelper.number_to_currency(amount, precision: 2, separator: '.',
                                                                                unit: parent.currency || '')
      "#{soll_account} => #{haben_account} #{formatted_amount} (#{book_type}): #{text}"
    end

    def invoice_part
      @invoice_part ||= parent&.invoice&.invoice_parts&.find(invoice_part_id) if invoice_part_id.present?
    end

    def vat_category
      @vat_category ||= parent&.booking&.organisation&.vat_categories&.find(vat_category_id) if vat_category_id.present? # rubocop:disable Style/SafeNavigationChainLength
    end

    def vat_breakup
      vat_category&.breakup(brutto: amount)
    end

    def equivalent?(other)
      irrelevant_attributes = %w[text]
      parent == other&.parent &&
        attributes.except(*irrelevant_attributes) == other&.attributes&.except(*irrelevant_attributes)
    end

    def invert
      self.soll_account, self.haben_account = haben_account, soll_account
      self
    end

    def abs
      return self unless amount.negative?

      invert
      self.amount = amount.abs
      self
    end
  end
end
