# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_questions
#
#  id                 :bigint           not null, primary key
#  booking_agent_mode :integer          default("not_visible")
#  description_i18n   :jsonb            not null
#  discarded_at       :datetime
#  key                :string
#  label_i18n         :jsonb            not null
#  options            :jsonb
#  ordinal            :integer
#  required           :boolean          default(FALSE)
#  tenant_mode        :integer          default("not_visible"), not null
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
#
class BookingQuestion < ApplicationRecord
  MODES = { not_visible: 0, provisional_editable: 1, always_editable: 2, blank_editable: 3 }.freeze
  extend TemplateRenderable
  include TemplateRenderable
  extend Mobility
  include RankedModel
  include Subtypeable
  include Discard::Model

  belongs_to :organisation, inverse_of: :booking_questions
  has_many :tarifs, dependent: :restrict_with_error, inverse_of: :prefill_usage_booking_question,
                    foreign_key: :prefill_usage_booking_question_id
  has_many :booking_question_responses, dependent: :destroy, inverse_of: :booking_question
  has_many :applying_conditions, -> { qualifiable_group(:applying) }, as: :qualifiable, dependent: :destroy,
                                                                      class_name: :BookingCondition, inverse_of: false

  enum :tenant_mode, MODES, prefix: :tenant, default: :not_visible
  enum :booking_agent_mode, MODES, prefix: :booking_agent, default: :not_visible

  scope :ordered, -> { rank(:ordinal) }
  scope :include_conditions, -> { includes(:applying_conditions) }
  ranks :ordinal, with_same: :organisation_id, class_name: 'BookingQuestion'

  translates :label, column_suffix: '_i18n', locale_accessors: true
  translates :description, column_suffix: '_i18n', locale_accessors: true

  validates :type, presence: true, inclusion: { in: ->(_) { BookingQuestion.subtypes.keys.map(&:to_s) } }
  validates :tenant_mode, :booking_agent_mode, presence: true
  validate { errors.add(:required, :invalid) if required && tenant_not_visible? }

  before_validation :update_booking_conditions

  accepts_nested_attributes_for :applying_conditions, allow_destroy: true,
                                                      reject_if: :reject_booking_conditition_attributes?

  def cast(value)
    ActiveModel::Type::String.new.cast(value)
  end

  def reject_booking_conditition_attributes?(attributes)
    attributes[:type].blank?
  end

  def update_booking_conditions
    applying_conditions.each { |condition| condition.assign_attributes(qualifiable: self, group: :applying) }
  end

  def applies_to_booking?(booking)
    applying_conditions.none? || BookingCondition.fullfills_all?(booking, applying_conditions)
  end

  def self.applying_to_booking(booking)
    return none if booking&.organisation.blank?

    booking.organisation.booking_questions.include_conditions.ordered.filter do |question|
      question.applies_to_booking?(booking)
    end
  end
end
