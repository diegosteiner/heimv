# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_logs
#
#  id         :integer          not null, primary key
#  booking_id :uuid             not null
#  user_id    :integer
#  trigger    :integer          not null
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_booking_logs_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe Booking::Log, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
