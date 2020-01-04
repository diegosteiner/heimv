# == Schema Information
#
# Table name: organisations
#
#  id                              :bigint           not null, primary key
#  address                         :text
#  booking_ref_strategy_type       :string
#  booking_strategy_type           :string
#  contract_representative_address :string
#  currency                        :string           default("CHF")
#  delivery_method_settings_url    :string
#  email                           :string
#  esr_participant_nr              :string
#  iban                            :string
#  invoice_ref_strategy_type       :string
#  message_footer                  :text
#  name                            :string
#  payment_information             :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'rails_helper'

RSpec.describe Organisation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
