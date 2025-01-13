# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_parts
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

module InvoiceParts
  class Deposit < Add
    InvoicePart.register_subtype self

    attr_accessor :reassign_payments

    after_save :reassign_payments!

    attribute :accounting_account_nr
    attribute :vat_category_id

    def reassign_payments!(payments = reassign_payments)
      return unless valid? && apply

      payments&.each { |payment| payment&.update!(invoice:) }
    end
  end
end
