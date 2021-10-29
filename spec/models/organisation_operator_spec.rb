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
require 'rails_helper'

RSpec.describe OrganisationOperator, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
