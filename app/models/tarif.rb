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
#  label_i18n                        :jsonb
#  minimum_price_per_night           :decimal(, )
#  minimum_price_total               :decimal(, )
#  minimum_usage_per_night           :decimal(, )
#  minimum_usage_total               :decimal(, )
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

  scope :ordered, -> { order(:ordinal) }
  scope :pinned, -> { where(pin: true) }

  validates :selecting_conditions, :enabling_conditions, store_model: true, allow_nil: true
  validates :type, presence: true, inclusion: { in: ->(_) { Tarif.subtypes.keys.map(&:to_s) } }
  # there are cases where neither is needed
  # validates :vat_category_id, presence: true, if: -> { organisation&.accounting_settings&.liable_for_vat }
  # validates :accounting_account_nr, presence: true, if: -> { organisation&.accounting_settings&.enabled }

  translates :label, column_suffix: '_i18n', locale_accessors: true
  translates :unit, column_suffix: '_i18n', locale_accessors: true

  accepts_nested_attributes_for :selecting_conditions, :enabling_conditions, allow_destroy: true

  def before_usage_validation(_usage); end
  def before_usage_save(_usage); end
  def validate_usage(_usage); end

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

  def minimums
    {
      minimum_usage_per_night:,
      minimum_usage_total:,
      minimum_price_per_night:,
      minimum_price_total:
    }
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
