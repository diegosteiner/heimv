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
    formatted_percentage = ActiveSupport::NumberHelper.number_to_percentage(percentage, precision: 2)
    return formatted_percentage if label.blank?

    "#{label} (#{formatted_percentage})"
  end

  def tax_of(amount)
    return 0 if percentage.blank? || percentage.zero?

    amount / (100 + percentage) * percentage
  end
end
