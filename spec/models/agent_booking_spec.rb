# == Schema Information
#
# Table name: agent_bookings
#
#  id                 :uuid             not null, primary key
#  accepted_request   :boolean
#  booking_agent_code :string
#  booking_agent_ref  :string
#  committed_request  :boolean
#  remarks            :text
#  tenant_email       :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  home_id            :bigint
#  organisation_id    :bigint
#
# Indexes
#
#  index_agent_bookings_on_booking_id       (booking_id)
#  index_agent_bookings_on_home_id          (home_id)
#  index_agent_bookings_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe AgentBooking, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
