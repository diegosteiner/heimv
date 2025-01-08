# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_parts
#
#  id                        :integer          not null, primary key
#  invoice_id                :integer
#  usage_id                  :integer
#  type                      :string
#  amount                    :decimal(, )
#  label                     :string
#  breakdown                 :string
#  ordinal                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  vat_category_id           :integer
#  accounting_account_nr     :string
#  accounting_cost_center_nr :string
#
# Indexes
#
#  index_invoice_parts_on_invoice_id       (invoice_id)
#  index_invoice_parts_on_usage_id         (usage_id)
#  index_invoice_parts_on_vat_category_id  (vat_category_id)
#

module InvoiceParts
  class Title < Text
    InvoicePart.register_subtype self
  end
end
