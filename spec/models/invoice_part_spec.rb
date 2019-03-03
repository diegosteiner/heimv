# == Schema Information
#
# Table name: invoice_parts
#
#  id         :bigint(8)        not null, primary key
#  invoice_id :bigint(8)
#  usage_id   :bigint(8)
#  type       :string
#  amount     :decimal(, )
#  label      :string
#  label_2    :string
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe InvoicePart, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
