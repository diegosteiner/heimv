# frozen_string_literal: true

# == Schema Information
#
# Table name: homes
#
#  id               :bigint           not null, primary key
#  address          :text
#  booking_margin   :integer          default(0)
#  janitor          :text
#  min_occupation   :integer
#  name             :string
#  ref              :string
#  requests_allowed :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_homes_on_organisation_id          (organisation_id)
#  index_homes_on_ref_and_organisation_id  (ref,organisation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

# RSpec.describe Home, type: :model do
# end
