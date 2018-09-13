class TarifSelector < ApplicationRecord
  DISTINCTION_REGEX = /\A\w*\z/

  belongs_to :home, inverse_of: :tarif_selectors
  has_many :tarif_tarif_selectors, dependent: :destroy, inverse_of: :tarif_selector
  has_many :tarifs, through: :tarif_tarif_selectors

  accepts_nested_attributes_for :tarif_tarif_selectors, reject_if: :all_blank, allow_destroy: true

  def vote_for(usage)
    tarif_tarif_selectors.includes(tarif: :booking_copies).map { |tuc| tuc.vote_for(usage) }.compact
  end

  def self.types
    %w[TarifSelectors::BookingNights TarifSelectors::BookingApproximateHeadcountPerNight
       TarifSelectors::AlwaysApply TarifSelectors::BookingOvernightStays
       TarifSelectors::BookingPurpose]
  end

  def valid_tarifs
    home.tarifs
  end
end
