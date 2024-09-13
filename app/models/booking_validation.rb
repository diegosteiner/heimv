# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_validations
#
#  id                 :bigint           not null, primary key
#  error_message_i18n :jsonb
#  ordinal            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_booking_validations_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
class BookingValidation < ApplicationRecord
  extend Mobility
  include RankedModel
  include Discard::Model

  belongs_to :organisation, inverse_of: :booking_validations

  has_many :validating_conditions, -> { qualifiable_group(:validating) }, as: :qualifiable, dependent: :destroy,
                                                                          class_name: :BookingCondition,
                                                                          inverse_of: false
  has_many :enabling_conditions, -> { qualifiable_group(:enabling) }, as: :qualifiable, dependent: :destroy,
                                                                      class_name: :BookingCondition,
                                                                      inverse_of: false

  translates :error_message, column_suffix: '_i18n', locale_accessors: true

  scope :ordered, -> { order(:ordinal) }
  ranks :ordinal, with_same: :organisation_id, class_name: 'BookingValidation'

  before_validation :update_booking_conditions

  accepts_nested_attributes_for :enabling_conditions, allow_destroy: true,
                                                      reject_if: :reject_booking_conditition_attributes?
  accepts_nested_attributes_for :validating_conditions, allow_destroy: true,
                                                        reject_if: :reject_booking_conditition_attributes?

  def reject_booking_conditition_attributes?(attributes)
    attributes[:type].blank?
  end

  def update_booking_conditions
    enabling_conditions.each { |condition| condition.assign_attributes(qualifiable: self, group: :enabling) }
    validating_conditions.each { |condition| condition.assign_attributes(qualifiable: self, group: :validating) }
  end

  def validate_booking(booking)
    return true if !enabled_by_condition?(booking) || valid_by_condition?(booking)

    booking.errors.add(:base, error_message)
    false
  end

  def enabled_by_condition?(booking)
    enabling_conditions.none? || BookingCondition.fullfills_all?(booking, enabling_conditions)
  end

  def valid_by_condition?(booking)
    validating_conditions.any? && BookingCondition.fullfills_all?(booking, validating_conditions)
  end
end