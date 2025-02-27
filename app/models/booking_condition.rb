# frozen_string_literal: true

class BookingCondition
  # extend ActiveModel::Translation
  include StoreModel::Model
  include ActiveModel::Validations::Callbacks
  include Subtypeable
  extend Translatable
  include Translatable

  attribute :id, :string
  attribute :type, :string
  attribute :organisation_id, :string

  validates :type, presence: true, inclusion: { in: ->(_) { BookingCondition.subtypes.keys.map(&:to_s) } }
  validates :organisation, presence: true

  delegate :compare_attributes, to: :class
  delegate :stringify_keys, to: :attributes

  before_validation do
    self.id = id.presence || Digest::UUID.uuid_v4
    self.type = self.class.model_name.to_s
  end

  def fullfills?(booking)
    evaluate(booking)
  end

  def evaluate(booking)
    evaluate!(booking)
  rescue StandardError => e
    ExceptionNotifier.notify_exception(e) if defined?(ExceptionNotifier)
    nil
  end

  def qualifiable
    parent.is_a?(BookingCondition) ? parent.qualifiable : parent
  end

  delegate :organisation, to: :qualifiable, allow_nil: true

  def organisation=(value)
    # self.organisation_id = value.is_a?(Organisation) ? value.id : value
  end

  def self.one_of
    StoreModel.one_of { subtypes[(it[:type].presence || it['type'].presence)&.to_sym] || BookingCondition }
  end

  def self.options_for_select(organisation)
    subtypes.transform_values do |subtype|
      {
        type: subtype.name,
        name: subtype.model_name.human,
        compare_attributes: subtype.try(:compare_attributes_for_select),
        compare_operators: subtype.try(:compare_operators_for_select),
        compare_value_regex: subtype.try(:compare_value_regex).present?,
        compare_values: subtype.try(:compare_values_for_select, organisation)
      }
    end
  end
end
