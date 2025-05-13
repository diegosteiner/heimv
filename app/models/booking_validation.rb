# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_validations
#
#  id                    :bigint           not null, primary key
#  check_on              :integer          default(0), not null
#  enabling_conditions   :jsonb
#  error_message_i18n    :jsonb            not null
#  ordinal               :integer
#  validating_conditions :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  organisation_id       :bigint           not null
#

class BookingValidation < ApplicationRecord
  extend Mobility
  include RankedModel
  include Discard::Model
  include StoreModel::NestedAttributes

  belongs_to :organisation, inverse_of: :booking_validations

  translates :error_message, column_suffix: '_i18n', locale_accessors: true

  flag :check_on, Booking::VALIDATION_CONTEXTS

  attribute :validating_conditions, BookingCondition.one_of.to_array_type
  attribute :enabling_conditions, BookingCondition.one_of.to_array_type

  scope :ordered, -> { order(:ordinal) }
  ranks :ordinal, with_same: :organisation_id, class_name: 'BookingValidation'

  validates :validating_conditions, :enabling_conditions, store_model: true, allow_nil: true

  accepts_nested_attributes_for :enabling_conditions, :validating_conditions, allow_destroy: true

  def booking_valid?(booking, validation_context:)
    return true unless check_on.include?(validation_context) && enabled_by_conditions?(booking)

    valid_by_conditions?(booking)
  end

  def enabled_by_conditions?(booking)
    enabling_conditions.blank? || enabling_conditions.all? { it.fullfills?(booking) }
  end

  def valid_by_conditions?(booking)
    validating_conditions&.all? { it.fullfills?(booking) }
  end
end
