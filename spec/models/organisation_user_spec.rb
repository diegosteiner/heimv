# frozen_string_literal: true

# == Schema Information
#
# Table name: organisation_users
#
#  id              :integer          not null, primary key
#  organisation_id :integer          not null
#  user_id         :integer          not null
#  role            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  token           :string
#
# Indexes
#
#  index_organisation_users_on_organisation_id              (organisation_id)
#  index_organisation_users_on_organisation_id_and_user_id  (organisation_id,user_id) UNIQUE
#  index_organisation_users_on_user_id                      (user_id)
#

require 'rails_helper'

RSpec.describe OrganisationUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
