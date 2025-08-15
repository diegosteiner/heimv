# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id                        :bigint           not null, primary key
#  accounting_account_nr     :string
#  accounting_cost_center_nr :string
#  amount                    :decimal(, )
#  breakdown                 :string
#  label                     :string
#  ordinal                   :integer
#  type                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invoice_id                :bigint
#  usage_id                  :bigint
#  vat_category_id           :bigint
#

class Invoice
  module Items
    class Deposit < Add
      Invoice::Item.register_subtype self

      def deposit
        invoice.booking.invoices.deposits.find_by(id: deposit_id)
      end

      def vat_category_required?
        false
      end
    end
  end
end
