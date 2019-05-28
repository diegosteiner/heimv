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

class InvoicePart < ApplicationRecord
  belongs_to :invoice, inverse_of: :invoice_parts, touch: true
  belongs_to :usage, inverse_of: :invoice_parts, optional: true

  attribute :apply, :boolean, default: true

  after_save do
    invoice.recalculate_amount
  end

  before_validation do
    self.amount = amount.floor(2)
  end

  acts_as_list scope: [:invoice_id]

  validates :type, presence: true
end
