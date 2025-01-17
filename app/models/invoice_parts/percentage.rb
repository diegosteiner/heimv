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
  class Percentage < InvoicePart
    InvoicePart.register_subtype self

    def calculated_amount
      sum_of_predecessors * amount / 100
    end

    def breakdown
      self[:breakdown].presence ||
        ActiveSupport::NumberHelper.number_to_percentage(amount, precision: 0)
    end
  end
end
