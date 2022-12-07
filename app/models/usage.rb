# frozen_string_literal: true

# == Schema Information
#
# Table name: usages
#
#  id                  :bigint           not null, primary key
#  committed           :boolean          default(FALSE)
#  presumed_used_units :decimal(, )
#  price_per_unit      :decimal(, )
#  remarks             :text
#  used_units          :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid
#  tarif_id            :bigint
#
# Indexes
#
#  index_usages_on_booking_id               (booking_id)
#  index_usages_on_tarif_id_and_booking_id  (tarif_id,booking_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (tarif_id => tarifs.id)
#

class Usage < ApplicationRecord
  PREFILL_METHODS = {
    flat: -> { 1 },
    nights: -> { booking.occupancy.nights },
    headcount_nights: -> { booking.occupancy.nights * (booking.approximate_headcount || 0) },
    headcount: -> { booking.approximate_headcount || 0 }
  }.with_indifferent_access.freeze

  belongs_to :tarif, -> { include_conditions }, inverse_of: :usages
  belongs_to :booking, inverse_of: :usages, touch: true
  has_many :invoice_parts, dependent: :nullify
  has_one :organisation, through: :booking

  attribute :apply, default: true

  before_validation { tarif&.before_usage_validation(self) }
  before_save { tarif&.before_usage_save(self) }
  before_create :pin_price_per_unit

  scope :ordered, -> { joins(:tarif).includes(:tarif).order(Tarif.arel_table[:ordinal].asc) }
  scope :of_tarif, ->(tarif) { where(tarif_id: tarif) }
  scope :amount, -> { joins(:tarif).where(tarifs: { type: Tarifs::Amount.to_s }) }

  validates :tarif_id, uniqueness: { scope: :booking_id }, allow_nil: true
  validates :used_units, numericality: true, allow_nil: true

  def price
    price_per_unit = self.price_per_unit.presence || tarif.price_per_unit.presence || 1.0
    price = (used_units || 0.0) * price_per_unit
    (price * 20.0).floor / 20.0
  end

  def presumed_units
    prefill_proc = PREFILL_METHODS.fetch(tarif.prefill_usage_method, nil)
    (prefill_proc && instance_exec(&prefill_proc)).presence
  end

  def pin_price_per_unit
    self.price_per_unit = (tarif.pin? && tarif.price_per_unit) || nil
  end

  def used?
    used_units.present? && used_units.positive?
  end

  def price_per_unit
    super || tarif&.price_per_unit
  end

  def breakdown
    tarif&.breakdown(self)
  end

  def updated_after_past?
    updated_at > booking.occupancy.ends_at
  end

  def enabled_by_condition?
    tarif.enabling_conditions.none? || BookingCondition.fullfills_all?(booking, tarif.enabling_conditions)
  end

  def selected_by_condition?
    enabled_by_condition? &&
      tarif.selecting_conditions.any? && BookingCondition.fullfills_all?(booking, tarif.selecting_conditions)
  end

  # TODO: decouple
  has_one :meter_reading_period, dependent: :nullify

  accepts_nested_attributes_for :meter_reading_period, reject_if: :all_blank
end
