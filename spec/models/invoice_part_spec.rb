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

require 'rails_helper'

RSpec.describe InvoicePart, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
