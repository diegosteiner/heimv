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

class InvoicePart < ApplicationRecord
  belongs_to :invoice, inverse_of: :invoice_parts, touch: true
  belongs_to :usage, inverse_of: :invoice_parts, optional: true

  attribute :apply, :boolean, default: true

  after_save do
    invoice.recalculate_amount if amount_previously_changed?
  end

  before_validation do
    self.amount = amount.floor(2)
  end

  acts_as_list scope: [:invoice_id]

  validates :type, presence: true
end
