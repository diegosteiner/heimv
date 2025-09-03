# frozen_string_literal: true

class Invoice
  module Items
    class Add < ::Invoice::Item
      Invoice::Item.register_subtype self

      validates :id, :vat_category_id, presence: true, if: :vat_category_required?
      validates :accounting_account_nr, presence: true, if: :accounting_account_nr_required?

      def calculated_amount
        amount
      end

      def accounting_account_nr_required?
        !to_sum(0).zero? && organisation&.accounting_settings&.enabled &&
          (invoice.new_record? || invoice.created_at&.>(Time.zone.local(2025, 6, 1))) # TODO: remove after a year
      end

      def vat_category_required?
        !to_sum(0).zero? && organisation&.accounting_settings&.liable_for_vat &&
          (invoice.new_record? || invoice.created_at&.>(Time.zone.local(2025, 6, 1))) # TODO: remove after a year
      end
    end
  end
end
