class Usage < ApplicationRecord
  belongs_to :tarif, inverse_of: :usages
  belongs_to :booking, inverse_of: :usages
  has_many :invoice_parts, dependent: :nullify

  attribute :apply, default: true

  scope :ordered, -> { order(tarif: { row_order: :ASC, created_at: :ASC }) }

  def price
    (used_units || 1) * tarif.price_per_unit
  end

  def used_units
    return 1 if tarif.is_a?(Tarifs::Flat)
  end

  before_create do
    unless tarif.booking_copy? || tarif.transient?
      self.tarif = TarifBuilder.new.booking_copy_for(tarif, booking).tap(&:save)
    end
  end
end
