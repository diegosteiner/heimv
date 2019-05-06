# == Schema Information
#
# Table name: invoice_parts
#
#  id         :bigint           not null, primary key
#  invoice_id :bigint
#  usage_id   :bigint
#  type       :string
#  amount     :decimal(, )
#  label      :string
#  label_2    :string
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module InvoiceParts
  class Add < InvoicePart
    def inject_self(result)
      result + amount
    end
  end
end
