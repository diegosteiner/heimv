# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id          :bigint           not null, primary key
#  sent_at     :date
#  signed_at   :date
#  text        :text
#  valid_from  :datetime
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  booking_id  :uuid
#
# Indexes
#
#  index_contracts_on_booking_id  (booking_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

require 'rails_helper'

RSpec.describe Contract, type: :model do
  let(:organisation) { create(:organisation) }
  let(:booking) { create(:booking, organisation: organisation) }
  let(:contract) { build(:contract, booking: booking) }

  describe '#save' do
    it do
      expect(contract.save).to be true
      expect(contract.pdf).to be_present
    end
  end
end
