# == Schema Information
#
# Table name: usages
#
#  id         :bigint(8)        not null, primary key
#  tarif_id   :bigint(8)
#  used_units :decimal(, )
#  remarks    :text
#  booking_id :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Usage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
