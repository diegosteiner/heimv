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
  has_many :applying_conditions, -> { qualifiable_group(:applying) }, as: :qualifiable, dependent: :destroy,
                                                                      class_name: :BookingCondition, inverse_of: false
  scope :ordered, -> { order(:ordinal) }
  ranks :ordinal, with_same: :organisation_id

  translates :label, column_suffix: '_i18n', locale_accessors: true
  translates :description, column_suffix: '_i18n', locale_accessors: true

  def value_for(booking)
    booking&.booking_questions&.[](id.to_s)
  end

  def validate_booking(booking)
    return unless required && value_for(booking).blank?

    booking.errors.add(ActiveModel::NestedError.new(form_input_name,
                                                    :presence))
  end

  def cast(value)
    ActiveModel::Type::String.new.cast(value)
  end

  def form_input_name
    "booking_questions[#{id}]"
  end

  def form_error_name
    "booking_questions.#{id}"
  end

  def applies_to_booking?(booking)
    applying_conditions.none? || BookingCondition.fullfills_all?(booking, applying_conditions)
  end

  def self.validate_booking(booking)
    where(organisation: booking&.organisation).map do |booking_question|
      next unless booking_question.applies_to_booking?(booking)

      booking_question.validate_booking(booking)
    end
  end
end
