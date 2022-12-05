# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                      :bigint           not null, primary key
#  accountancy_account     :string
#  associated_types        :integer          default(0), not null
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
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  home_id                 :bigint
#  organisation_id         :bigint           not null
#
# Indexes
#
#  index_tarifs_on_home_id          (home_id)
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
  flag :associated_types, ASSOCIATED_TYPES.keys

  belongs_to :home, optional: true
  belongs_to :organisation, inverse_of: :tarifs
  has_many :usages, dependent: :restrict_with_error, inverse_of: :tarif
  has_many :booking_conditions, as: :qualifiable, dependent: :destroy
  has_many :meter_reading_periods, dependent: :destroy, inverse_of: :tarif
  has_many :bookings, through: :usages, inverse_of: :tarifs

  scope :ordered, -> { order(:ordinal) }
  scope :pinned, -> { where(pin: true) }
  # scope :valid_now, -> { where(valid_until: nil) }

  enum prefill_usage_method: Usage::PREFILL_METHODS.keys.index_with(&:to_s)

  validates :type, presence: true
  attribute :price_per_unit, default: 0

  translates :label, column_suffix: '_i18n', locale_accessors: true
  translates :unit, column_suffix: '_i18n', locale_accessors: true

  accepts_nested_attributes_for :booking_conditions, reject_if: :reject_booking_conditition_attributes?,
                                                     allow_destroy: true

  def unit_prefix
    self.class.human_attribute_name(:unit_prefix, default: '')
  end

  def unit_with_prefix
    [unit_prefix, unit].compact_blank.join(' ')
  end

  def before_usage_validation(_usage); end

  def before_usage_save(_usage); end

  def price(usage)
    used_units = usage.used_units || 0.0
    price_per_unit = usage.price_per_unit.presence || self.price_per_unit.presence || 1.0
    round(used_units * price_per_unit)
  end

  def breakdown(usage)
    key ||= :flat if is_a?(Tarifs::Flat)
    key ||= :default
    I18n.t(key, scope: 'invoice_parts.breakdown', **breakdown_options(usage))
  end

  def <=>(other)
    ordinal <=> other.ordinal
  end

  def reject_booking_conditition_attributes?(attributes)
    attributes[:type].blank?
  end

  private

  def breakdown_options(usage)
    {
      used_units: number_to_rounded(usage.used_units || 0, precision: 2, strip_insignificant_zeros: true),
      unit: unit, price_per_unit: number_to_currency(price_per_unit || 0, currency: organisation.currency)
    }
  end

  def round(price)
    (price * 20.0).floor / 20.0
  end

  def initialize_copy(origin)
    super
    self.booking_conditions = origin.booking_conditions.map(&:dup)
  end
end
