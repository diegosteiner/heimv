# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_parts
#
#  id         :bigint           not null, primary key
#  amount     :decimal(, )
#  breakdown  :string
#  label      :string
#  ordinal    :integer
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
  include RankedModel

  belongs_to :invoice, inverse_of: :invoice_parts, touch: true
  belongs_to :usage, inverse_of: :invoice_parts, optional: true

  attribute :apply, :boolean, default: true

  ranks :ordinal, with_same: :invoice_id

  scope :ordered, -> { rank(:ordinal) }

  validates :type, presence: true

  before_validation do
    self.amount = amount&.floor(2) || 0
  end

  after_save do
    invoice.recalculate! if amount_previously_changed?
  end
end
