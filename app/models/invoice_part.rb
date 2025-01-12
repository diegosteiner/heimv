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
# Indexes
#
#  index_invoice_parts_on_invoice_id       (invoice_id)
#  index_invoice_parts_on_usage_id         (usage_id)
#  index_invoice_parts_on_vat_category_id  (vat_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#  fk_rails_...  (usage_id => usages.id)
#  fk_rails_...  (vat_category_id => vat_categories.id)
#

class InvoicePart < ApplicationRecord
  include Subtypeable
  include RankedModel
  extend TemplateRenderable
  include TemplateRenderable

  belongs_to :invoice, inverse_of: :invoice_parts, touch: true
  belongs_to :usage, inverse_of: :invoice_parts, optional: true
  belongs_to :vat_category, optional: true

  has_one :tarif, through: :usage
  has_one :booking, through: :usage

  attribute :apply, :boolean, default: true

  delegate :booking, :organisation, to: :invoice

  ranks :ordinal, with_same: :invoice_id, class_name: 'InvoicePart'

  scope :ordered, -> { rank(:ordinal) }

  validates :type, inclusion: { in: ->(_) { InvoicePart.subtypes.keys.map(&:to_s) } }

  before_validation do
    self.amount = amount&.floor(2) || 0
  end

  def calculated_amount
    amount
  end

  def vat_breakdown
    @vat_breakdown ||= vat_category&.breakdown(amount) || { brutto: amount, netto: amount, vat: 0 }
  end

  def accounting_cost_center_nr
    @accounting_cost_center_nr ||= if super.to_s == 'home'
                                     invoice.booking.home&.settings&.accounting_cost_center_nr.presence
                                   else
                                     super.presence
                                   end
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

  class Filter < ApplicationFilter
    attribute :homes, default: -> { [] }
    attribute :issued_at_after, :datetime
    attribute :issued_at_before, :datetime

    filter :homes do |invoice_parts|
      relevant_homes = Array.wrap(homes).compact_blank
      if relevant_homes.present?
        invoice_parts.joins(invoice: :booking).where(invoices: { bookings: { home_id: relevant_homes } })
      end
    end

    filter :issued_at do |invoice_parts|
      next unless issued_at_before.present? || issued_at_after.present?

      invoice_parts.joins(:invoice).where(Invoice.arel_table[:issued_at].between(issued_at_after..issued_at_before))
    end
  end
end
