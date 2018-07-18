class Usage < ApplicationRecord
  belongs_to :tarif, inverse_of: :usages
  belongs_to :booking, inverse_of: :usages
  has_many :invoice_parts

  scope :ordered, -> { order(tarif: { position: :ASC, created_at: :ASC }) }

  def price
    (used_units || 1) * tarif.price_per_unit
  end
end
