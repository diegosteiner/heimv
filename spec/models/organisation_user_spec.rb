# frozen_string_literal: true

# == Schema Information
#
# Table name: organisation_users
#
#  id              :bigint           not null, primary key
#  role            :integer          not null
#  token           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#  user_id         :bigint           not null
#

require 'rails_helper'

RSpec.describe OrganisationUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
