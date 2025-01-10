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
    enum :book_type, { main: 0, cost: 1, vat: 2 }, prefix: true, default: :main

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

    def to_h
      {
        account_nr:, amount:, side:, book_type:, text:, vat_category_id:, invoice_part_id:
      }
    end

    def journal_entry
      parent
    end

    def invoice_part
      @invoice_part ||= parent&.invoice&.invoice_parts&.find(invoice_part_id) if invoice_part_id.present?
    end

    def vat_category
      @vat_category ||= parent&.booking&.organisation&.vat_categories&.find(vat_category_id) if vat_category_id.present? # rubocop:disable Style/SafeNavigationChainLength
    end
  end
end
