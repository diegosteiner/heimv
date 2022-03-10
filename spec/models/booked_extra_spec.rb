# frozen_string_literal: true

# == Schema Information
#
# Table name: booked_extras
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  bookable_extra_id :bigint           not null
#  booking_id        :uuid             not null
#
# Indexes
#
#  index_booked_extras_on_bookable_extra_id  (bookable_extra_id)
#
# Foreign Keys
#
#  fk_rails_...  (bookable_extra_id => bookable_extras.id)
#
require 'rails_helper'

RSpec.describe BookedExtra, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
