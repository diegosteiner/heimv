# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_validations
#
#  id                   :bigint           not null, primary key
#  check_on             :integer          default(0), not null
#  enabling_condition   :jsonb
#  error_message_i18n   :jsonb            not null
#  ordinal              :integer
#  validating_condition :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organisation_id      :bigint           not null
#

class BookingValidation < ApplicationRecord
  extend Mobility
  include RankedModel
  include Discard::Model
  include StoreModel::NestedAttributes

  belongs_to :organisation, inverse_of: :booking_validations

  translates :error_message, column_suffix: '_i18n', locale_accessors: true

  flag :check_on, Booking::VALIDATION_CONTEXTS

  attribute :validating_condition, BookingCondition.one_of.to_type
  attribute :enabling_condition, BookingCondition.one_of.to_type

  scope :ordered, -> { order(:ordinal) }
  ranks :ordinal, with_same: :organisation_id, class_name: 'BookingValidation'

  validates :validating_condition, :enabling_condition, store_model: true, allow_nil: true

  accepts_nested_attributes_for :enabling_condition, :validating_condition, allow_destroy: true

  def booking_valid?(booking, validation_context:)
    return true unless check_on.include?(validation_context) && enabled_by_condition?(booking)

    valid_by_condition?(booking)
  end

  def enabled_by_condition?(booking)
    enabling_condition.blank? || enabling_condition.fullfills?(booking)
  end

  def valid_by_condition?(booking)
    validating_condition&.fullfills?(booking)
  end
end
