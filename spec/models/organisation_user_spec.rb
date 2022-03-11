# frozen_string_literal: true

# == Schema Information
#
# Table name: organisation_users
#
#  id              :bigint           not null, primary key
#  role            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_organisation_users_on_organisation_id              (organisation_id)
#  index_organisation_users_on_organisation_id_and_user_id  (organisation_id,user_id) UNIQUE
#  index_organisation_users_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe OrganisationUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
