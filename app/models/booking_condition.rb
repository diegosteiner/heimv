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

class BookingCondition < ApplicationRecord
  include Subtypeable
  extend Translatable
  include Translatable

  EQUALITY_OPERATORS = {
    '=': ->(actual_value:, compare_value:) { actual_value == compare_value },
    '!=': ->(actual_value:, compare_value:) { actual_value != compare_value }
  }.freeze

  NUMERIC_OPERATORS = {
    '>': ->(actual_value:, compare_value:) { actual_value > compare_value },
    '>=': ->(actual_value:, compare_value:) { actual_value >= compare_value },
    '<': ->(actual_value:, compare_value:) { actual_value < compare_value },
    '<=': ->(actual_value:, compare_value:) { actual_value <= compare_value }
  }.reverse_merge(EQUALITY_OPERATORS).freeze

  belongs_to :qualifiable, polymorphic: true, optional: true
  belongs_to :organisation

  scope :qualifiable_group, ->(group) { where(group:) }
  delegate :compare_operators_for_select, to: :class

  validates :type, presence: true, inclusion: { in: ->(_) { BookingCondition.subtypes.keys.map(&:to_s) } }
  validates :compare_value, format: { with: ->(condition) { condition.compare_value_regex } }, allow_blank: true
  validate do
    errors.add(:compare_operator, :inclusion) if compare_operator.present? &&
                                                 !self.class.compare_operators&.key?(compare_operator.to_sym)
    errors.add(:compare_attribute, :inclusion) if compare_attribute.present? &&
                                                  !compare_attributes&.key?(compare_attribute.to_sym)
  end

  delegate :compare_attributes, to: :class

  def compare_values
    nil
  end

  def compare_value_regex
    //
  end

  def compare_operators_for_select
    self.class.compare_operators&.keys&.map do |operator|
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

  def fullfills?(booking)
    evaluate(booking) || (must_condition ? false : nil)
  end

  def evaluate(booking)
    evaluate!(booking)
  rescue StandardError => e
    ExceptionNotifier.notify_exception(e) if defined?(ExceptionNotifier)
    nil
  end

  def evaluate_operator(operator, with: {})
    instance_exec(**with, &self.class.compare_operators.fetch(operator&.to_sym))
  end

  def evaluate_attribute(attribute, with: {})
    instance_exec(**with, &compare_attributes.fetch(attribute&.to_sym))
  end

  def to_s
    "#{model_name.human}: #{compare_attribute} #{compare_operator} #{compare_value}"
  end

  def qualifiable=(value)
    self.organisation ||= value.try(:organisation)
    super
  end

  class << self
    def fullfills_all?(booking, booking_conditions)
      booking_conditions.map { _1.fullfills?(booking) }.compact.all?
    end

    def compare_operators
      @compare_operators ||= {}
    end

    def compare_operator(**args)
      compare_operators.merge!(args.symbolize_keys)
    end

    def compare_attributes
      @compare_attributes ||= {}
    end

    def compare_attribute(**args)
      compare_attributes.merge!(args.symbolize_keys)
    end
  end
end
