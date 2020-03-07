# == Schema Information
#
# Table name: usages
#
#  id                  :bigint           not null, primary key
#  presumed_used_units :decimal(, )
#  remarks             :text
#  used_units          :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid
#  tarif_id            :bigint
#
# Indexes
#
#  index_usages_on_booking_id  (booking_id)
#  index_usages_on_tarif_id    (tarif_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (tarif_id => tarifs.id)
#

require 'rails_helper'

RSpec.describe Usage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
