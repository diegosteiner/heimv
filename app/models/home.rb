# == Schema Information
#
# Table name: homes
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  ref        :string
#  place      :string
#  janitor    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Home < ApplicationRecord
  validates :name, :ref, presence: true
  has_one_attached :house_rules
  has_many :occupancies, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :tarifs, ->(home) { Tarif.where(home: home, booking: nil) },
           dependent: :destroy, inverse_of: :home
  has_many :tarif_selectors, inverse_of: :home, dependent: :destroy
  has_many :meter_reading_periods, -> { ordered }, through: :tarifs, inverse_of: :home, dependent: :destroy

  accepts_nested_attributes_for :tarifs, reject_if: :all_blank, update_only: true

  def to_s
    name
  end

  def to_liquid
    Public::HomeSerializer.new(self).serializable_hash.deep_stringify_keys
  end
end
