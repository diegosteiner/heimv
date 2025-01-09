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

    def invoice_part
      @invoice_part ||= parent&.invoice&.invoice_parts&.find(id: invoice_part_id)
    end

    def vat_category
      @vat_category ||= parent&.booking&.organisation&.vat_categories&.find(id: vat_category_id) # rubocop:disable Style/SafeNavigationChainLength
    end
  end
end
