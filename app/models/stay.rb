class Stay < ApplicationRecord
  belongs_to :booking
  has_many :tarifs, inverse_of: :stay, dependent: :destroy
  # has_many :us, inverse_of: :stay, dependent: :destroy

  accepts_nested_attributes_for :tarifs, reject_if: :all_blank
end
