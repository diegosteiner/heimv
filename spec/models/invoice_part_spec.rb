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

require 'rails_helper'

RSpec.describe InvoicePart, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
