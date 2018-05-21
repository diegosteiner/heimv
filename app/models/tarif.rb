class Tarif < ApplicationRecord
  TYPES = [Tarif::Amount, Tarif::Flat, Tarif::Metered].freeze
  belongs_to :stay, optional: true
  has_one :booking, autosave: false
  belongs_to :home, optional: true
  belongs_to :template, class_name: :Tarif, optional: true, inverse_of: :template_instances
  has_many :template_instances, class_name: :Tarif, dependent: :nullify, inverse_of: :template,
                                foreign_key: :template_id
  has_many :usages, dependent: :nullify, inverse_of: :tarif

  scope :ordered, -> { order(position: :ASC, created_at: :ASC) }

  def parent
    booking || home
  end
end
