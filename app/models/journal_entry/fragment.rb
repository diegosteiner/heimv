# frozen_string_literal: true

class JournalEntry
  class Fragment
    include StoreModel::Model

    attribute :amount, :decimal
    attribute :account_nr, :string
    attribute :text, :string
    attribute :invoice_part_id, :integer
    attribute :vat_category_id, :integer

    enum :side, { soll: 1, haben: -1 }
    enum :book_type, { main: 0, cost: 1, vat: 2 }, _prefix: true, default: :main # rubocop:disable Rails/EnumSyntax

    validates :account_nr, :side, :amount, :book_type, presence: true
    validates :amount, numericality: { other_than: 0 }

    def soll_account
      account_nr if soll?
    end

    def haben_account
      account_nr if haben?
    end

    def soll_amount
      amount if soll?
    end

    def haben_amount
      amount if haben?
    end

    def journal_entry
      parent
    end

    def related(book_type)
      journal_entry.fragment_relations[invoice_part_id]&.fetch(book_type&.to_sym, nil)
    end

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
      attributes.slice(*%w[account_nr side amount book_type]) ==
        other.attributes.slice(*%w[account_nr side amount book_type])
    end

    def invert
      return self.side = :haben if soll?
      return self.side = :soll if haben?

      nil
    end
  end
end
