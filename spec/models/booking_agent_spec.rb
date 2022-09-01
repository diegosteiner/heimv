# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_agents
#
#  id                       :bigint           not null, primary key
#  address                  :text
#  code                     :string
#  email                    :string
#  name                     :string
#  provision                :decimal(, )
#  request_deadline_minutes :integer          default(14400)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  organisation_id          :bigint           default(1), not null
#
# Indexes
#
#  index_booking_agents_on_code_and_organisation_id  (code,organisation_id) UNIQUE
#  index_booking_agents_on_organisation_id           (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe BookingAgent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
