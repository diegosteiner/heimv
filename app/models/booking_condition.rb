# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_conditions
#
#  id                :bigint           not null, primary key
#  compare_attribute :string
#  compare_operator  :string
#  compare_value     :string
#  group             :string
#  must_condition    :boolean          default(TRUE)
#  qualifiable_type  :string
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organisation_id   :bigint
#  qualifiable_id    :bigint
#
# Indexes
#
#  index_booking_conditions_on_organisation_id                      (organisation_id)
#  index_booking_conditions_on_qualifiable                          (qualifiable_id,qualifiable_type,group)
#  index_booking_conditions_on_qualifiable_id_and_qualifiable_type  (qualifiable_id,qualifiable_type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class BookingCondition < ApplicationRecord
  include Subtypeable

  belongs_to :qualifiable, polymorphic: true, optional: true
  belongs_to :organisation

  validates :type, inclusion: { in: ->(_) { BookingCondition.subtypes.keys.map(&:to_s) } }

  scope :qualifiable_group, ->(group) { where(group: group) }

  def self.compare_value_regex
    //
  end

  def self.binary_comparison(value, other_value, operator: '==')
    {
      '<' => -> { value < other_value },
      '<=' => -> { value <= other_value },
      '>' => -> { value > other_value },
      '>=' => -> { value >= other_value }
    }.fetch(operator, -> { value == other_value }).call
  end

  def self.fullfills_all?(booking, booking_conditions)
    booking_conditions.map do |condition|
      condition.evaluate(booking) || (condition.must_condition ? false : nil)
    end.compact.all?

    # TODO: rescue?
  end

  def compare_value_match
    @compare_value_match ||= self.class.compare_value_regex.match(compare_value)
  end

  validates :compare_value, format: { with: compare_value_regex }, allow_blank: true
  validates :type, presence: true

  def to_s
    "#{model_name.human}: #{compare_value}"
  end

  def qualifiable=(value)
    self.organisation ||= value.try(:organisation)
    super
  end

  def evaluate(booking)
    booking.present?
  end
end
