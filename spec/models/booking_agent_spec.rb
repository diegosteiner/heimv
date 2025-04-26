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
#  organisation_id          :bigint           not null
#

require 'rails_helper'

RSpec.describe BookingAgent do
  pending "add some examples to (or delete) #{__FILE__}"
end
