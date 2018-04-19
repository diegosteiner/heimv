class Tarif < ApplicationRecord
  TYPES = [Tarif::Amount, Tarif::Flat, Tarif::Metered].freeze
  belongs_to :booking, optional: true
  belongs_to :home, optional: true
  belongs_to :template, class_name: :Tarif, optional: true, inverse_of: :template_instances
  has_many :template_instances, class_name: :Tarif, dependent: :nullify, inverse_of: :template

  scope :ordered, -> { order(position: :ASC) }

  def parent
    booking || home
  end
end
