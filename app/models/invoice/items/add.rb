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
        parent.is_a?(Invoice) && !to_sum(0).zero? && organisation&.accounting_settings&.enabled &&
          !legacy_invoice?
      end

      def vat_category_required?
        parent.is_a?(Invoice) && !to_sum(0).zero? && organisation&.accounting_settings&.liable_for_vat &&
          !legacy_invoice?
      end

      # TODO: remove after a year
      def legacy_invoice?
        parent.is_a?(Invoice) && (parent&.new_record? || parent&.created_at&.>(Time.zone.local(2025, 6, 1)))
      end
    end
  end
end
