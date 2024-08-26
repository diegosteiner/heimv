# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                                :bigint           not null, primary key
#  accountancy_account               :string
#  associated_types                  :integer          default(0), not null
#  discarded_at                      :datetime
#  label_i18n                        :jsonb
#  minimum_usage_per_night           :decimal(, )
#  minimum_usage_total               :decimal(, )
#  ordinal                           :integer
#  pin                               :boolean          default(TRUE)
#  prefill_usage_method              :string
#  price_per_unit                    :decimal(, )
#  tarif_group                       :string
#  type                              :string
#  unit_i18n                         :jsonb
#  valid_from                        :datetime
#  valid_until                       :datetime
#  vat                               :decimal(, )
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  organisation_id                   :bigint           not null
#  prefill_usage_booking_question_id :bigint
#
# Indexes
#
#  index_tarifs_on_discarded_at                       (discarded_at)
#  index_tarifs_on_organisation_id                    (organisation_id)
#  index_tarifs_on_prefill_usage_booking_question_id  (prefill_usage_booking_question_id)
#  index_tarifs_on_type                               (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#  fk_rails_...  (prefill_usage_booking_question_id => booking_questions.id)
#

class Tarif < ApplicationRecord
  ASSOCIATED_TYPES = { deposit: Invoices::Deposit, invoice: Invoices::Invoice, late_notice: Invoices::LateNotice,
                       offer: Invoices::Offer, contract: ::Contract }.freeze
  PREFILL_METHODS = {
    flat: -> { 1 },
    days: -> { booking.nights + 1 },
    nights: -> { booking.nights },
    headcount_nights: -> { booking.nights * (booking.approximate_headcount || 0) },
    headcount: -> { booking.approximate_headcount || 0 }
  }.with_indifferent_access.freeze

  include ActiveSupport::NumberHelper

  extend TemplateRenderable
  include TemplateRenderable
  extend Mobility
  include Subtypeable
  include Discard::Model
  flag :associated_types, ASSOCIATED_TYPES.keys

  belongs_to :organisation, inverse_of: :tarifs
  belongs_to :prefill_usage_booking_question, class_name: 'BookingQuestion', inverse_of: :tarifs, optional: true
  has_many :meter_reading_periods, dependent: :destroy, inverse_of: :tarif
  has_many :bookings, through: :usages, inverse_of: :tarifs
  has_many :usages, dependent: :restrict_with_error, inverse_of: :tarif
  has_many :selecting_conditions, -> { qualifiable_group(:selecting) }, as: :qualifiable, dependent: :destroy,
                                                                        class_name: :BookingCondition, inverse_of: false
  has_many :enabling_conditions, -> { qualifiable_group(:enabling) }, as: :qualifiable, dependent: :destroy,
                                                                      class_name: :BookingCondition, inverse_of: false

  enum :prefill_usage_method, Tarif::PREFILL_METHODS.keys.index_with(&:to_s)

  scope :ordered, -> { order(:ordinal) }
  scope :pinned, -> { where(pin: true) }
  scope :include_conditions, -> { includes(:selecting_conditions, :enabling_conditions) }

  validates :type, presence: true, inclusion: { in: ->(_) { Tarif.subtypes.keys.map(&:to_s) } }
  attribute :price_per_unit, default: 0

  translates :label, column_suffix: '_i18n', locale_accessors: true
  translates :unit, column_suffix: '_i18n', locale_accessors: true

  accepts_nested_attributes_for :enabling_conditions, allow_destroy: true,
                                                      reject_if: :reject_booking_conditition_attributes?
  accepts_nested_attributes_for :selecting_conditions, allow_destroy: true,
                                                       reject_if: :reject_booking_conditition_attributes?

  before_validation :update_booking_conditions

  def unit_prefix
    self.class.human_attribute_name(:unit_prefix, default: '')
  end

  def unit_with_prefix
    [unit_prefix, unit].compact_blank.join(' ')
  end

  def before_usage_validation(_usage); end

  def before_usage_save(_usage); end

  def prefill_usage_booking_questions
    booking_question_types = %w[BookingQuestions::Integer]
    organisation.booking_questions.ordered.where(type: booking_question_types)
  end

  def presumed_units_question_factor(usage)
    booking_question = prefill_usage_booking_question
    return nil if booking_question.blank? || usage&.booking&.blank?

    usage.booking.booking_question_responses.find_by(booking_question:)&.value.presence || 0
  end

  def presumed_units_prefill_factor(usage)
    prefill_proc = PREFILL_METHODS[prefill_usage_method]
    return if prefill_proc.blank?

    usage.instance_exec(&prefill_proc).presence || 0
  end

  def presumed_units(usage)
    return nil if presumed_units_prefill_factor(usage).blank? &&
                  presumed_units_question_factor(usage).blank?

    (presumed_units_prefill_factor(usage).presence || 1) * (presumed_units_question_factor(usage).presence || 1)
  end

  def breakdown(usage)
    key ||= :flat if is_a?(Tarifs::Flat)
    key ||= :minimum if usage.minimum_price?
    key ||= :default
    I18n.t(key, scope: 'invoice_parts.breakdown', **breakdown_options(usage))
  end

  def <=>(other)
    ordinal <=> other.ordinal
  end

  def to_s
    "##{ordinal}: #{label} (#{self.class.model_name.human})"
  end

  def reject_booking_conditition_attributes?(attributes)
    attributes[:type].blank?
  end

  def update_booking_conditions
    enabling_conditions.each { |condition| condition.assign_attributes(qualifiable: self, group: :enabling) }
    selecting_conditions.each { |condition| condition.assign_attributes(qualifiable: self, group: :selecting) }
  end

  private

  def breakdown_options(usage)
    {
      unit:,
      minimum: '',
      used_units: number_to_rounded(usage.used_units || 0, precision: 2, strip_insignificant_zeros: true),
      price_per_unit: number_to_currency(usage.price_per_unit.presence || 0, unit: organisation.currency)
    }
  end

  def initialize_copy(origin)
    super
    self.selecting_conditions = origin.selecting_conditions.map(&:dup)
    self.enabling_conditions = origin.enabling_conditions.map(&:dup)
  end
end
