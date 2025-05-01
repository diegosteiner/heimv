# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_logs
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  trigger    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :uuid             not null
#  user_id    :bigint
#

require 'rails_helper'

RSpec.describe Booking::Log do
  pending "add some examples to (or delete) #{__FILE__}"
end
