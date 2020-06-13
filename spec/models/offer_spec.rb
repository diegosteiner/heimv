# == Schema Information
#
# Table name: offers
#
#  id          :bigint           not null, primary key
#  text        :text
#  valid_from  :datetime
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  booking_id  :uuid
#
# Indexes
#
#  index_offers_on_booking_id  (booking_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#
require 'rails_helper'

RSpec.describe Offer, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
