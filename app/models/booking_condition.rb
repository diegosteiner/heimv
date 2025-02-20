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
    StoreModel.one_of { subtypes[it[:type]&.to_sym] || BookingCondition }
  end
end
