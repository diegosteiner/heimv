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

      attr_accessor :reassign_payments

      # after_save :reassign_payments!

      def vat_category_required?
        false
      end

      def reassign_payments!(payments = reassign_payments)
        return unless valid? && apply

        payments&.each { |payment| payment&.update!(invoice:) }
      end
    end
  end
end
