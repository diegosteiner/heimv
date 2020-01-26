# == Schema Information
#
# Table name: invoice_parts
#
#  id         :bigint           not null, primary key
#  amount     :decimal(, )
#  label      :string
#  label_2    :string
#  position   :integer
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  invoice_id :bigint
#  usage_id   :bigint
#
# Indexes
#
#  index_invoice_parts_on_invoice_id  (invoice_id)
#  index_invoice_parts_on_usage_id    (usage_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#  fk_rails_...  (usage_id => usages.id)
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
