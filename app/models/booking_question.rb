# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_questions
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb
#  discarded_at     :datetime
#  key              :string
#  label_i18n       :jsonb
#  options          :jsonb
#  ordinal          :integer
#  required         :boolean          default(FALSE)
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_booking_questions_on_discarded_at     (discarded_at)
#  index_booking_questions_on_organisation_id  (organisation_id)
#  index_booking_questions_on_type             (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
class BookingQuestion < ApplicationRecord
  extend TemplateRenderable
  include TemplateRenderable
  extend Mobility
  include RankedModel
  include Subtypeable
  include Discard::Model

  belongs_to :organisation, inverse_of: :booking_questions
  has_many :booking_question_responses, dependent: :destroy, inverse_of: :booking_question
  has_many :applying_conditions, -> { qualifiable_group(:applying) }, as: :qualifiable, dependent: :destroy,
                                                                      class_name: :BookingCondition, inverse_of: false
  scope :ordered, -> { order(:ordinal) }
  scope :include_conditions, -> { includes(:applying_conditions) }
  ranks :ordinal, with_same: :organisation_id

  translates :label, column_suffix: '_i18n', locale_accessors: true
  translates :description, column_suffix: '_i18n', locale_accessors: true

  validates :type, presence: true, inclusion: { in: ->(_) { BookingQuestion.subtypes.keys.map(&:to_s) } }
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
    booking.organisation.booking_questions.include_conditions.filter do |question|
      question.applies_to_booking?(booking)
    end
  end
end
