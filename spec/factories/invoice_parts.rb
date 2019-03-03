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

FactoryBot.define do
  factory :invoice_part, class: InvoiceParts::Add.to_s do
    invoice { nil }
    usage { nil }
    # type ''
    amount { '9.99' }
    label { 'MyText' }
    label_2 { 'MyText' }
  end
end
