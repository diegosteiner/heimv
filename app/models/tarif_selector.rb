# == Schema Information
#
# Table name: tarif_selectors
#
#  id         :bigint           not null, primary key
#  position   :integer
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  home_id    :bigint
#
# Indexes
#
#  index_tarif_selectors_on_home_id  (home_id)
#  index_tarif_selectors_on_type     (type)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#

class TarifSelector < ApplicationRecord
  DISTINCTION_REGEX = /\A\w*\z/.freeze

  belongs_to :home, inverse_of: :tarif_selectors
  has_many :tarif_tarif_selectors, dependent: :destroy, inverse_of: :tarif_selector
  has_many :tarifs, through: :tarif_tarif_selectors

  accepts_nested_attributes_for :tarif_tarif_selectors, reject_if: :all_blank, allow_destroy: true

  def valid_tarifs
    home.tarifs
  end
end

TarifSelectors
