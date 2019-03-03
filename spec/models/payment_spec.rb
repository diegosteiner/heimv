# == Schema Information
#
# Table name: payments
#
#  id         :bigint(8)        not null, primary key
#  amount     :decimal(, )
#  paid_at    :date
#  ref        :string
#  invoice_id :bigint(8)
#  booking_id :uuid
#  data       :text
#  remarks    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Payment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
