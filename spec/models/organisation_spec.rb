# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  address                   :text
#  bcc                       :string
#  booking_ref_strategy_type :string
#  booking_strategy_type     :string
#  currency                  :string           default("CHF")
#  email                     :string
#  esr_participant_nr        :string
#  iban                      :string
#  invoice_ref_strategy_type :string
#  location                  :string
#  mail_from                 :string
#  message_footer            :text
#  messages_enabled          :boolean          default(TRUE)
#  name                      :string
#  payment_deadline          :integer          default(30), not null
#  representative_address    :string
#  slug                      :string
#  smtp_url                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_organisations_on_slug  (slug) UNIQUE
#

require 'rails_helper'

RSpec.describe Organisation, type: :model do
  let(:organisation) { build(:organisation) }

  describe '#save' do
    it do
      expect(organisation.save).to be true
    end
  end
end
