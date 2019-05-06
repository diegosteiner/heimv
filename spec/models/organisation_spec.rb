# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  name                      :string
#  address                   :text
#  booking_strategy_type     :string
#  invoice_ref_strategy_type :string
#  payment_information       :text
#  account_nr                :string
#  message_footer            :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'rails_helper'

RSpec.describe Organisation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
