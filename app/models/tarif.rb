# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                                :bigint           not null, primary key
#  accounting_account_nr             :string
#  accounting_cost_center_nr         :string
#  associated_types                  :integer          default(0), not null
#  discarded_at                      :datetime
#  enabling_conditions               :jsonb
#  included_units                    :decimal(, )
#  included_units_mode               :integer          default(0)
#  label_i18n                        :jsonb
#  minimum                           :decimal(, )
#  minimum_mode                      :integer          default(0)
#  mode                              :integer
#  ordinal                           :integer
#  pin                               :boolean          default(TRUE)
#  prefill_usage_method              :string
#  price_per_unit                    :decimal(, )
#  selecting_conditions              :jsonb
#  tarif_group                       :string
#  type                              :string
#  unit_i18n                         :jsonb
#  valid_from                        :datetime
#  valid_until                       :datetime
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  organisation_id                   :bigint           not null
#  prefill_usage_booking_question_id :bigint
#  vat_category_id                   :bigint
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

  extend TemplateRenderable
  include TemplateRenderable
  extend Mobility
  include Subtypeable
  include Discard::Model
  include StoreModel::NestedAttributes

  flag :associated_types, ASSOCIATED_TYPES.keys

  belongs_to :organisation, inverse_of: :tarifs
  belongs_to :vat_category, inverse_of: :tarifs, optional: true
  belongs_to :prefill_usage_booking_question, class_name: 'BookingQuestion', inverse_of: :tarifs, optional: true
  has_many :meter_reading_periods, dependent: :destroy, inverse_of: :tarif
  has_many :bookings, through: :usages, inverse_of: :tarifs
  has_many :usages, dependent: :restrict_with_error, inverse_of: :tarif

  attribute :price_per_unit, default: 0
  attribute :selecting_conditions, BookingCondition.one_of.to_array_type, nil: true
  attribute :enabling_conditions, BookingCondition.one_of.to_array_type, nil: true

  enum :prefill_usage_method, Tarif::PREFILL_METHODS.keys.index_with(&:to_s)
  enum :minimum_mode, { none: 0, usage_per_night: 1, usage_per_day: 2, usage_total: 3,
                        price_per_night: 4, price_per_day: 5, price_total: 6 }, prefix: :minimum
  enum :included_units_mode, { none: 0, usage_per_night: 1, usage_per_day: 2, usage_total: 3 }, prefix: :included_units

  scope :ordered, -> { order(:ordinal) }
  scope :pinned, -> { where(pin: true) }

  validates :selecting_conditions, :enabling_conditions, store_model: true, allow_nil: true
  validates :type, presence: true, inclusion: { in: ->(_) { Tarif.subtypes.keys.map(&:to_s) } }
  validates :minimum, :included_units, inclusion: { in: 0.. }, allow_nil: true
  # there are cases where neither is needed
  # validates :vat_category_id, presence: true, if: -> { organisation&.accounting_settings&.liable_for_vat }
  # validates :accounting_account_nr, presence: true, if: -> { organisation&.accounting_settings&.enabled }

  translates :label, column_suffix: '_i18n', locale_accessors: true
  translates :unit, column_suffix: '_i18n', locale_accessors: true

  accepts_nested_attributes_for :selecting_conditions, :enabling_conditions, allow_destroy: true

  before_validation do
    self.minimum = nil if minimum_none?
    self.included_units = nil if included_units_none?
  end

  def prefill_usage_booking_questions
    booking_question_types = %w[BookingQuestions::Integer]
    organisation.booking_questions.ordered.where(type: booking_question_types)
  end

  def <=>(other)
    ordinal <=> other.ordinal
  end

  def to_s
    "##{ordinal}: [#{tarif_group}] #{label} (#{self.class.model_name.human})"
  end

  def build_usage(**attributes)
    self.class::Usage.new(**attributes, tarif: self)
  end

  class Usage < ::Usage
  end

  private

  def initialize_copy(origin)
    super
    self.selecting_conditions = origin.selecting_conditions.dup
    self.enabling_conditions = origin.enabling_conditions.dup
  end
end
