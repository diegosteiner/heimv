# == Schema Information
#
# Table name: organisation_operators
#
#  id              :bigint           not null, primary key
#  ordinal         :integer
#  remarks         :text
#  responsibility  :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  home_id         :bigint
#  operator_id     :bigint           not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_organisation_operators_on_home_id          (home_id)
#  index_organisation_operators_on_operator_id      (operator_id)
#  index_organisation_operators_on_ordinal          (ordinal)
#  index_organisation_operators_on_organisation_id  (organisation_id)
#  index_organisation_operators_on_responsibility   (responsibility)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (operator_id => operators.id)
#  fk_rails_...  (organisation_id => organisations.id)
#
class OrganisationOperator < ApplicationRecord
  RESPONSIBILITIES = { administration: 0, home_handover: 1, home_return: 2, billing: 3 }.freeze

  include RankedModel

  belongs_to :home, inverse_of: :organisation_operators
  belongs_to :organisation, inverse_of: :organisation_operators
  belongs_to :operator, inverse_of: :organisation_operators

  enum responsibility: OrganisationOperator::RESPONSIBILITIES, _suffix: true
  ranks :ordinal, with_same: :organisation_id

  validates :responsibility, presence: true
end
