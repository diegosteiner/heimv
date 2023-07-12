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
  extend Translatable
  include Translatable

  NUMERIC_OPERATORS = {
    '=': ->(value, compare_value) { value == compare_value },
    '>': ->(value, compare_value) { value > compare_value },
    '>=': ->(value, compare_value) { value >= compare_value },
    '<': ->(value, compare_value) { value < compare_value },
    '<=': ->(value, compare_value) { value <= compare_value }
  }.freeze

  belongs_to :qualifiable, polymorphic: true, optional: true
  belongs_to :organisation

  scope :qualifiable_group, ->(group) { where(group: group) }
  delegate :compare_operators_for_select, to: :class

  validates :type, presence: true, inclusion: { in: ->(_) { BookingCondition.subtypes.keys.map(&:to_s) } }
  validates :compare_value, format: { with: ->(condition) { condition.compare_value_regex } }, allow_blank: true
  validate do
    errors.add(:compare_attribute, :inclusion) unless compare_attribute.blank? ||
                                                      compare_attributes&.keys&.include?(compare_attribute.to_sym)
    errors.add(:compare_operator, :inclusion) unless compare_operator.blank? ||
                                                     compare_operators&.keys&.include?(compare_operator.to_sym)
  end

  def compare_attributes
    nil
  end

  def compare_operators
    nil
  end

  def compare_values
    nil
  end

  def compare_value_regex
    //
  end

  def compare_operators_for_select
    compare_operators&.keys&.map do |operator|
      [operator.to_s, operator.to_sym]
      # [translate(operator, scope: :operators, default: operator), operator.to_sym]
    end
  end

  def compare_values_for_select
    compare_values&.map do |value|
      next if value.blank?

      next [value.to_s, value.id] if value.is_a?(ApplicationRecord)
      next [value.last, value.first] if value.is_a?(Array)

      [value.to_s, value.to_sym || value.to_s]
    end
  end

  def compare_attributes_for_select
    compare_attributes&.keys&.map do |attribute|
      [translate(attribute, scope: :attributes, default: attribute), attribute.to_sym]
    end
  end

  def self.fullfills_all?(booking, booking_conditions)
    booking_conditions.map do |condition|
      condition.evaluate(booking) || (condition.must_condition ? false : nil)
    end.compact.all?

    # TODO: rescue?
  end

  def evaluate(booking)
    evaluate_operator(booking)
  end

  def evaluate_operator(booking, operator: compare_operator)
    compare_operators_for_select[operator].call(booking, compare_value)
  end

  def to_s
    "#{model_name.human}: #{compare_value}"
  end

  def qualifiable=(value)
    self.organisation ||= value.try(:organisation)
    super
  end
end
