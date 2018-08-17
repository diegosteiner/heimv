class Usage < ApplicationRecord
  belongs_to :tarif, inverse_of: :usages
  belongs_to :booking, inverse_of: :usages
  has_many :invoice_parts, dependent: :nullify

  attribute :apply, default: false

  scope :ordered, -> { order(tarif: { row_order: :ASC, created_at: :ASC }) }

  before_create :create_tarif_booking_copy

  validates :tarif_id, uniqueness: { scope: :booking_id }, allow_nil: true

  def price
    (used_units || 1) * tarif.price_per_unit
  end

  def used_units
    super unless tarif.override_used_units?
    tarif.override_used_units(self)
  end

  def create_tarif_booking_copy
    return if tarif.booking_copy? || tarif.transient?
    self.tarif = TarifBuilder.new.booking_copy_for(tarif, booking).tap(&:save)
  end
end
