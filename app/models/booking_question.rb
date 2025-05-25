# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_questions
#
#  id                  :bigint           not null, primary key
#  applying_conditions :jsonb
#  booking_agent_mode  :integer          default("not_visible")
#  description_i18n    :jsonb            not null
#  discarded_at        :datetime
#  key                 :string
#  label_i18n          :jsonb            not null
#  options             :jsonb
#  ordinal             :integer
#  required            :boolean          default(FALSE)
#  tenant_mode         :integer          default("not_visible"), not null
#  type                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organisation_id     :bigint           not null
#
class BookingQuestion < ApplicationRecord
  MODES = { not_visible: 0, provisional_editable: 1, always_editable: 2, blank_editable: 3 }.freeze
  extend TemplateRenderable
  include TemplateRenderable
  extend Mobility
  include RankedModel
  include Subtypeable
  include Discard::Model
  include StoreModel::NestedAttributes

  belongs_to :organisation, inverse_of: :booking_questions
  has_many :tarifs, dependent: :restrict_with_error, inverse_of: :prefill_usage_booking_question,
                    foreign_key: :prefill_usage_booking_question_id
  has_many :booking_question_responses, dependent: :destroy, inverse_of: :booking_question

  enum :tenant_mode, MODES, prefix: :tenant, default: :not_visible
  enum :booking_agent_mode, MODES, prefix: :booking_agent, default: :not_visible

  attribute :applying_conditions, BookingCondition.one_of.to_array_type, nil: true

  scope :ordered, -> { rank(:ordinal) }
  ranks :ordinal, with_same: :organisation_id, class_name: 'BookingQuestion'

  translates :label, column_suffix: '_i18n', locale_accessors: true
  translates :description, column_suffix: '_i18n', locale_accessors: true

  validates :type, presence: true, inclusion: { in: ->(_) { BookingQuestion.subtypes.keys.map(&:to_s) } }
  validates :tenant_mode, :booking_agent_mode, presence: true
  validates :applying_conditions, store_model: true, allow_nil: true
  validate { errors.add(:required, :invalid) if required && tenant_not_visible? }

  accepts_nested_attributes_for :applying_conditions, allow_destroy: true

  def cast(value)
    ActiveModel::Type::String.new.cast(value)
  end

  def applies_to_booking?(booking)
    applying_conditions.blank? || applying_conditions.all? { it.fullfills?(booking) }
  end

  def self.applying_to_booking(booking)
    return none if booking&.organisation.blank?

    booking.organisation.booking_questions.ordered.filter do |question|
      question.applies_to_booking?(booking)
    end
  end
end
