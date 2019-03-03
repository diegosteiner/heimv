# == Schema Information
#
# Table name: booking_agents
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  code       :string
#  email      :string
#  address    :text
#  provision  :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe BookingAgent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
