# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_parts
#
#  id         :integer          not null, primary key
#  invoice_id :integer
#  usage_id   :integer
#  type       :string
#  amount     :decimal(, )
#  label      :string
#  breakdown  :string
#  ordinal    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vat        :decimal(, )
#
# Indexes
#
#  index_invoice_parts_on_invoice_id  (invoice_id)
#  index_invoice_parts_on_usage_id    (usage_id)
#

module InvoiceParts
  class Text < InvoicePart
    InvoicePart.register_subtype self

    def calculated_amount
      nil
    end

    def to_sum(sum)
      sum
    end
  end
end
