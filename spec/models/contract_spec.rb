# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                        :bigint           not null, primary key
#  locale                    :string
#  sent_at                   :date
#  signed_at                 :date
#  text                      :text
#  valid_from                :datetime
#  valid_until               :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  booking_id                :uuid
#  sent_with_notification_id :bigint
#

require 'rails_helper'

RSpec.describe Contract do
  let(:organisation) { create(:organisation) }
  let(:booking) { create(:booking, organisation:) }
  let(:contract) { build(:contract, booking:) }

  describe '#save' do
    it do
      expect(contract.save).to be true
      expect(contract.pdf).to be_present
    end
  end
end
