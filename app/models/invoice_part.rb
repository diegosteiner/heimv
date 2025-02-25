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

class InvoicePart
  include Subtypeable
  extend TemplateRenderable
  include TemplateRenderable
  include StoreModel::Model

  Subtypes = StoreModel.one_of { it[:type]&.constantize }

  attribute :apply, :boolean, default: true
  attribute :id, :string
  attribute :accounting_account_nr, :string
  attribute :accounting_cost_center_nr, :string
  attribute :amount, :decimal
  attribute :breakdown, :string
  attribute :label, :string
  attribute :ordinal, :integer
  attribute :type, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
  attribute :usage_id, :integer
  attribute :vat_category_id, :integer

  # belongs_to :invoice, inverse_of: :invoice_parts, touch: true
  belongs_to :usage, inverse_of: :invoice_parts, optional: true
  belongs_to :vat_category, optional: true

  has_one :tarif, through: :usage
  has_one :booking, through: :usage

  delegate :booking, :organisation, to: :parent

  validates :type, inclusion: { in: ->(_) { InvoicePart.subtypes.keys.map(&:to_s) } }

  before_validation do
    self.amount = amount&.floor(2) || 0
  end

  def calculated_amount
    amount
  end

  def type
    self.class.sti_name
  end

  def vat_breakdown
    @vat_breakdown ||= vat_category&.breakdown(amount) || { brutto: amount, netto: amount, vat: 0 }
  end

  def accounting_relevant?
    accounting_account_nr.present? && !to_sum(0).zero?
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
end
