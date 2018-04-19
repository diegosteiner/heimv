class Tarif < ApplicationRecord
  TYPES = [Tarif::Amount, Tarif::Flat, Tarif::Metered].freeze
  belongs_to :booking, optional: true
  belongs_to :home, optional: true
  belongs_to :template_tarif, class_name: :Tarif, optional: true

  scope :ordered, -> { order(position: :ASC) }

  def parent
    booking || home
  end
end
