# == Schema Information
#
# Table name: homes
#
#  id               :bigint           not null, primary key
#  janitor          :text
#  min_occupation   :integer
#  name             :string
#  place            :string
#  ref              :string
#  requests_allowed :boolean          default("false")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_homes_on_organisation_id  (organisation_id)
#  index_homes_on_ref              (ref) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe Home, type: :model do
end
