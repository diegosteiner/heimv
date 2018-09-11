class TarifSelector < ApplicationRecord
  DISTINCTION_REGEX = /\A\w*\z/

  belongs_to :home, inverse_of: :tarif_selectors
  has_many :tarif_tarif_selectors, dependent: :destroy, inverse_of: :tarif_selector
  has_many :tarifs, through: :tarif_tarif_selectors

  accepts_nested_attributes_for :tarif_tarif_selectors, reject_if: :all_blank, allow_destroy: true
  acts_as_list scope: [:home_id]

  def apply_all(booking, usages = booking.usages)
    # TODO: Maybe swap these loops for better performance?
    tarif_tarif_selectors.includes(tarif: :booking_copies).map do |tuc|
      usages.to_a.map do |usage|
        apply(usage, tuc) if usage.of_tarif?(tuc.tarif)
      end
    end
  end

  def apply(usage, tuc)
    usage.select_reason[self] = apply?(usage, tuc.distinction)
    usage.apply = apply?(usage, tuc.distinction) if usage.apply.nil? || tuc.override
    usage.apply
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
