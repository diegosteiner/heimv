# frozen_string_literal: true

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

  def breakdown(brutto)
    vat = 0
    vat = (brutto / (100 + percentage)) * percentage if percentage.present?
    { vat:, brutto: brutto, netto: (brutto - vat) }
  end

  def breakup(brutto: nil, netto: nil, vat: nil)
    return breakdown(brutto) if brutto.present?
    return breakdown((netto / 100) * (100 + percentage)) if netto.present?
    return breakdown((vat / percentage) * (100 + percentage)) if vat.present? && percentage&.positive?

    nil
  end
end
