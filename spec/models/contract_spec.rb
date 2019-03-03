# == Schema Information
#
# Table name: contracts
#
#  id          :bigint(8)        not null, primary key
#  booking_id  :uuid
#  sent_at     :date
#  signed_at   :date
#  text        :text
#  valid_from  :datetime
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Contract, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
