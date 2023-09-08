# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                      :bigint           not null, primary key
#  accountancy_account     :string
#  associated_types        :integer          default(0), not null
#  discarded_at            :datetime
#  label_i18n              :jsonb
#  minimum_usage_per_night :decimal(, )
#  minimum_usage_total     :decimal(, )
#  ordinal                 :integer
#  pin                     :boolean          default(TRUE)
#  prefill_usage_method    :string
#  price_per_unit          :decimal(, )
#  tarif_group             :string
#  type                    :string
#  unit_i18n               :jsonb
#  valid_from              :datetime
#  valid_until             :datetime
#  vat                     :decimal(, )
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organisation_id         :bigint           not null
#
# Indexes
#
#  index_tarifs_on_discarded_at     (discarded_at)
#  index_tarifs_on_organisation_id  (organisation_id)
#  index_tarifs_on_type             (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class Tarif < ApplicationRecord
  ASSOCIATED_TYPES = { deposit: Invoices::Deposit, invoice: Invoices::Invoice, late_notice: Invoices::LateNotice,
                       offer: Invoices::Offer, contract: ::Contract }.freeze
  include ActiveSupport::NumberHelper

  extend TemplateRenderable
  include TemplateRenderable
  extend Mobility
  include Subtypeable
  include Discard::Model
  flag :associated_types, ASSOCIATED_TYPES.keys

  belongs_to :organisation, inverse_of: :tarifs
  has_many :meter_reading_periods, dependent: :destroy, inverse_of: :tarif
  has_many :bookings, through: :usages, inverse_of: :tarifs
  has_many :usages, dependent: :restrict_with_error, inverse_of: :tarif
  has_many :selecting_conditions, -> { qualifiable_group(:selecting) }, as: :qualifiable, dependent: :destroy,
                                                                        class_name: :BookingCondition, inverse_of: false
  has_many :enabling_conditions, -> { qualifiable_group(:enabling) }, as: :qualifiable, dependent: :destroy,
                                                                      class_name: :BookingCondition, inverse_of: false
  scope :ordered, -> { order(:ordinal) }
  scope :pinned, -> { where(pin: true) }
  scope :include_conditions, -> { includes(:selecting_conditions, :enabling_conditions) }
  # scope :valid_now, -> { where(valid_until: nil) }

  validates :type, presence: true, inclusion: { in: ->(_) { Tarif.subtypes.keys.map(&:to_s) } }
  validates :prefill_usage_method, inclusion: { in: ->(tarif) { tarif.prefill_usage_method_options_for_select.keys } },
                                   allow_blank: true
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

  def breakdown(usage)
    key ||= :flat if is_a?(Tarifs::Flat)
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

  def prefill_usage_method_options_for_select
    built_in = Usage::PREFILL_METHODS.keys.to_h { [_1, Tarif.human_enum(:prefill_usage_methods, _1)] }
    booking_question_types = %w[BookingQuestions::Integer]
    booking_questions = organisation.booking_questions.ordered.where(type: booking_question_types).to_h do |question|
      [question.id, question.label]
    end
    built_in.merge(booking_questions).stringify_keys
  end

  private

  def breakdown_options(usage)
    {
      used_units: number_to_rounded(usage.used_units || 0, precision: 2, strip_insignificant_zeros: true),
      unit: unit, price_per_unit: number_to_currency(price_per_unit || 0, unit: organisation.currency)
    }
  end

  def initialize_copy(origin)
    super
    self.selecting_conditions = origin.selecting_conditions.map(&:dup)
    self.enabling_conditions = origin.enabling_conditions.map(&:dup)
  end
end
