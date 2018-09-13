class Home < ApplicationRecord
  validates :name, :ref, presence: true
  has_one_attached :house_rules
  has_many :occupancies, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :tarifs, ->(home) { Tarif.where(home: home, booking: nil).order(position: :ASC) },
    dependent: :destroy, inverse_of: :home
  has_many :tarif_selectors, inverse_of: :home, dependent: :destroy

  accepts_nested_attributes_for :tarifs, reject_if: :all_blank, update_only: true

  def to_s
    name
  end
end
