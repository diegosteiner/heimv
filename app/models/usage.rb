# frozen_string_literal: true

# == Schema Information
#
# Table name: usages
#
#  id             :bigint           not null, primary key
#  committed      :boolean          default(FALSE)
#  details        :jsonb
#  price_per_unit :decimal(, )
#  quoted_units   :decimal(, )
#  remarks        :text
#  type           :string           not null
#  used_units     :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  booking_id     :uuid
#  tarif_id       :bigint
#

class Usage < ApplicationRecord
  include ActiveSupport::NumberHelper
  include TemplateRenderable

  belongs_to :tarif, inverse_of: :usages
  belongs_to :booking, inverse_of: :usages, touch: true
  has_one :organisation, through: :booking

  attribute :apply, default: true
  delegate :tarif_group, to: :tarif, allow_nil: true

  # after_initialize :assert_usage_type!
  before_validation :assert_usage_type!
  before_create :pin_price_per_unit

  scope :ordered, -> { joins(:tarif).includes(:tarif).order(Tarif.arel_table[:ordinal].asc) }
  scope :of_tarif, ->(tarif) { where(tarif_id: tarif) }
  scope :amount, -> { joins(:tarif).where(tarifs: { type: Tarifs::Amount.to_s }) }

  validates :tarif_id, uniqueness: { scope: :booking_id }, allow_nil: true
  validates :used_units, numericality: true, allow_nil: true

  def assert_usage_type!
    becomes!(tarif.class::Usage) if tarif.present? && !is_a?(tarif.class::Usage)
  end

  def price(units = used_units)
    price = (units || 0.0) * (price_per_unit || 0.0)

    if price_per_unit&.negative?
      round_cents([price, minimum_price].compact.min)
    else
      round_cents([price, minimum_price].compact.max)
    end
  end

  def unit
    tarif&.unit
  end

  def minimum_price?
    return false if price.zero?

    price == minimum_price
  end

  def pin_price_per_unit
    self.price_per_unit = (tarif.pin? && tarif.price_per_unit) || nil
  end

  def used?
    used_units.present? && used_units.positive?
  end

  def price_per_unit
    super || tarif&.price_per_unit || 0.0
  end

  def updated_after_past?
    updated_at > booking.ends_at
  end

  def round_cents(amount, round_to: 5)
    multiplier = 100.0 / round_to
    (amount * multiplier).floor / multiplier
  end

  def items
    @items ||= booking.invoices.filter_map do |invoice|
      invoice.items.filter { it.usage_id == id }
    end.flatten
  end

  def enabled_by_conditions?
    tarif.enabling_conditions.blank? || tarif.enabling_conditions.all? { it.fullfills?(booking) }
  end

  def selected_by_conditions?
    tarif.selecting_conditions.presence&.all? { it.fullfills?(booking) }
  end

  def prefill_factor
    prefill_proc = Tarif::PREFILL_METHODS[tarif.prefill_usage_method]
    instance_exec(&prefill_proc).presence || 0 if prefill_proc.present?
  end

  def prefill_units
    return if prefill_factor.blank? && prefill_booking_question_factor.blank?

    (prefill_factor.presence || 1) * (prefill_booking_question_factor.presence || 1)
  end

  def prefill_booking_question_factor
    booking_question = tarif.prefill_usage_booking_question
    return nil if booking_question.blank? # || booking&.blank?

    booking.booking_question_responses.find_by(booking_question:)&.value.presence || 0
  end

  def minimum_prices
    nights = booking&.nights || 0

    {
      minimum_usage_per_night: tarif.minimum_usage_per_night&.*(nights)&.*(price_per_unit),
      minimum_usage_total: tarif.minimum_usage_total&.*(price_per_unit),
      minimum_price_per_night: tarif.minimum_price_per_night&.*(nights),
      minimum_price_total: tarif.minimum_price_total.presence
    }
  end

  def breakdown
    key ||= :minimum if minimum_price?
    key ||= :default

    I18n.t(key, scope: 'invoice_items.breakdown', unit:,
                minimum: (minimum_price && format_price(minimum_price)) || nil,
                used_units: format_units(used_units), price_per_unit: format_price(price_per_unit))
  end

  def minimum_price
    @minimum_price ||= if minimum_prices.values.compact.all?(&:negative?)
                         minimum_prices.values.compact.filter(&:negative?).min
                       else
                         minimum_prices.values.compact.filter(&:positive?).max
                       end
  end

  def critical_minimum
    @critical_minimum ||= minimum_price.present? && minimum_prices.find { minimum_price == _2 }&.first
  end

  def preselect
    self.apply ||= selected_by_conditions?
    self.used_units ||= prefill_units
  end

  def apply_to_invoice?(_invoice)
    true
  end

  def self.build(booking, tarifs: booking.organisation.tarifs.ordered.kept, preselect: false)
    usages = tarifs.where.not(id: booking.usages.pluck(:tarif_id)).filter_map do |tarif|
      tarif.build_usage(apply: nil, booking:)
    end
    usages.each(&:preselect) if preselect
    usages.filter(&:enabled_by_conditions?)
  end

  protected

  def format_units(units, precision: 2)
    number_to_rounded(units || 0, precision:, strip_insignificant_zeros: true)
  end

  def format_price(price = self.price)
    number_to_currency(price_per_unit.presence || 0, unit: organisation.currency)
  end
end
