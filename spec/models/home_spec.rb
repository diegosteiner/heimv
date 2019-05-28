# == Schema Information
#
# Table name: homes
#
#  id               :bigint           not null, primary key
#  organisation_id  :bigint           not null
#  name             :string
#  ref              :string
#  place            :string
#  janitor          :text
#  requests_allowed :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe Home, type: :model do
end
