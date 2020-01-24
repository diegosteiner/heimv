# == Schema Information
#
# Table name: tarif_selectors
#
#  id          :bigint           not null, primary key
#  distinction :string
#  type        :string
#  veto        :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tarif_id    :bigint
#
# Indexes
#
#  index_tarif_selectors_on_tarif_id  (tarif_id)
#
# Foreign Keys
#
#  fk_rails_...  (tarif_id => tarifs.id)
#

class TarifSelector < ApplicationRecord
  DISTINCTION_REGEX = /\A\w*\z/.freeze

  belongs_to :tarif, inverse_of: :tarif_selectors
  has_many :usages, through: :tarif
  has_one :home, through: :tarif

  validate do
    next if valid_tarifs.map(&:id).include?(tarif_id)

    errors.add(:tarif_id, :invalid)
  end

  validate do
    next if distinction.blank? || self.class::DISTINCTION_REGEX.match(distinction)

    errors.add(:distinction, :invalid)
  end

  def valid_tarifs
    home.tarifs
  end

  def vote_for(usage)
    return nil unless tarif == usage.tarif

    apply?(usage) || (veto ? false : nil)
  end

  def to_s
    [tarif_selector.model_name.human, distinction].compact.join(': ')
  end

  def apply?(_usage)
    true
  end
end
