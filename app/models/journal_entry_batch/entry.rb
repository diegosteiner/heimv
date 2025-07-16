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
    attribute :accounting_cost_center

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

    # def related_entries
    #   entries.filter { it.invoice_part_id = invoice_part_id }.group_by(&:book_type).symbolize_keys
    # end

    # def related(book_type)
    #   journal_entry_batch.entry_relations[invoice_part_id]&.fetch(book_type&.to_sym, nil)
    # end

    def invoice_part
      @invoice_part ||= parent&.invoice&.invoice_parts&.find(invoice_part_id) if invoice_part_id.present?
    end

    def vat_category
      @vat_category ||= parent&.booking&.organisation&.vat_categories&.find(vat_category_id) if vat_category_id.present? # rubocop:disable Style/SafeNavigationChainLength
    end

    def vat_breakup
      return vat_category&.breakup(vat: amount) if book_type_vat?
      return vat_category&.breakup(netto: amount) if book_type_main?

      nil
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
