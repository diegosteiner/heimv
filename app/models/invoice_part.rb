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

  ranks :ordinal, with_same: :invoice_id, class_name: 'InvoicePart'

  scope :ordered, -> { rank(:ordinal) }

  validates :type, presence: true

  before_validation do
    self.amount = amount&.floor(2) || 0
  end

  after_save do
    invoice.recalculate! if amount_previously_changed?
  end

  def calculated_amount
    amount
  end

  def sum_of_predecessors
    invoice.invoice_parts.ordered.inject(0) do |sum, invoice_part|
      break sum if invoice_part == self

      invoice_part.to_sum(sum)
    end
  end

  def to_sum(sum)
    sum + calculated_amount
  end

  def self.from_usage(usage, **attributes)
    return unless usage

    I18n.with_locale(usage.booking.locale) do
      new(attributes.reverse_merge(
            usage: usage, label: usage.tarif.label, breakdown: usage.breakdown,
            ordinal: usage.tarif.ordinal, amount: usage.price
          ))
    end
  end
end
