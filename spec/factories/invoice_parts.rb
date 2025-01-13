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

FactoryBot.define do
  factory :invoice_part, class: InvoiceParts::Add.to_s do
    usage { nil }
    invoice
    amount { usage&.price || rand(50.0..1000.0) }
    label { 'MyText' }
    breakdown { 'MyText' }
  end
end
