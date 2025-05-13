# frozen_string_literal: true

# == Schema Information
#
# Table name: vat_categories
#
#  id                  :bigint           not null, primary key
#  accounting_vat_code :string
#  discarded_at        :datetime
#  label_i18n          :jsonb            not null
#  percentage          :decimal(, )      default(0.0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organisation_id     :bigint           not null
#
class VatCategory < ApplicationRecord
  include Discard::Model
  extend Mobility

  belongs_to :organisation, inverse_of: :vat_categories
  has_many :tarifs, inverse_of: :vat_category, dependent: :restrict_with_error

  translates :label, column_suffix: '_i18n', locale_accessors: true

  validates :percentage, presence: true, numericality: { gteq: 0.0 }

  scope :ordered, -> { order(percentage: :ASC) }

  def to_s
    formatted_percentage = ActiveSupport::NumberHelper.number_to_percentage(percentage)
    return formatted_percentage if label.blank?

    "#{label} (#{formatted_percentage})"
  end

  def breakdown(brutto, round: 4)
    vat = 0
    vat = (brutto / (100 + percentage)) * percentage if percentage.present?
    { vat: vat.round(round), brutto: brutto.round(round), netto: (brutto - vat).round(round) }
  end

  def breakup(brutto: nil, netto: nil, vat: nil, round: 4)
    return breakdown(brutto) if brutto.present?
    return breakdown((netto / 100) * (100 + percentage)) if netto.present?
    return breakdown((vat / percentage) * (100 + percentage)) if vat.present? && percentage&.positive?

    nil
  end
end
