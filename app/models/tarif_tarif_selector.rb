class TarifTarifSelector < ApplicationRecord
  belongs_to :tarif, inverse_of: :tarif_tarif_selectors
  belongs_to :tarif_selector, inverse_of: :tarif_tarif_selectors
  has_many :usages, through: :tarif

  validate do
    next if tarif_selector.valid_tarifs.map(&:id).include?(tarif_id)
    errors.add(:tarif_id, :invalid)
  end

  validate do
    next if distinction.blank? || tarif_selector.class::DISTINCTION_REGEX.match(distinction)
    errors.add(:distinction, :invalid)
  end

  def vote_for(usage)
    return unless tarif == usage.tarif
    tarif_selector.apply?(usage, distinction) || (veto ? false : nil)
  end
end
