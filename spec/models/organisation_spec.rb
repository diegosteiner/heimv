# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  account_nr                :string
#  address                   :text
#  booking_strategy_type     :string
#  currency                  :string           default("CHF")
#  invoice_ref_strategy_type :string
#  message_footer            :text
#  name                      :string
#  payment_information       :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'rails_helper'

RSpec.describe Organisation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
