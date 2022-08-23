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

  belongs_to :tarif, -> { includes(:tarif_selectors) }, inverse_of: :usages
  belongs_to :booking, inverse_of: :usages
  has_many :invoice_parts, dependent: :nullify
  has_many :tarif_selectors, through: :tarif
  has_one :organisation, through: :booking

  attribute :apply, default: true

  before_validation { tarif&.before_usage_validation(self) }
  before_save { tarif&.before_usage_save(self) }
  before_create :pin_price_per_unit

  scope :ordered, -> { joins(:tarif).includes(:tarif).order(Tarif.arel_table[:ordinal].asc) }
  scope :of_tarif, ->(tarif) { where(tarif_id: tarif) }
  scope :amount, -> { joins(:tarif).where(tarifs: { type: Tarifs::Amount.to_s }) }
  scope :tenant_visible, -> { includes(:tarif).where(tarifs: { tenant_visible: true }) }

  validates :tarif_id, uniqueness: { scope: :booking_id }, allow_nil: true
  validates :used_units, numericality: true, allow_nil: true

  def price
    tarif&.price(self)
  end

  def presumed_units
    prefill_proc = PREFILL_METHODS.fetch(tarif.prefill_usage_method, nil)
    (prefill_proc && instance_exec(&prefill_proc)).presence
  end

  def pin_price_per_unit
    self.price_per_unit = (tarif.pin? && tarif.price_per_unit) || nil
  end

  def adopted_by_vote?
    votes = tarif_selectors.index_with do |selector|
      selector.vote_for(self)
    end
    votes = votes.values.flatten.compact
    votes.any? && votes.all?
  end

  def preselect
    self.apply ||= adopted_by_vote?
    self.used_units ||= presumed_units
    new_record?
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

  def to_liquid
    Manage::UsageSerializer.render_as_hash(self).deep_stringify_keys
  end

  # TODO: decouple
  has_one :meter_reading_period, dependent: :nullify

  accepts_nested_attributes_for :meter_reading_period, reject_if: :all_blank

  def build_meter_reading_period(attrs = {})
    super.tap do |meter_reading_period|
      meter_reading_period.start_value ||= MeterReadingPeriod.where(tarif: tarif)
                                                             .ordered&.last&.start_value
    end
  end
end
