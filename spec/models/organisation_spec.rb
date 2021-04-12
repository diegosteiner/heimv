# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  address                   :text
#  bcc                       :string
#  booking_flow_type         :string
#  currency                  :string           default("CHF")
#  default_payment_info_type :string
#  email                     :string
#  esr_beneficiary_account   :string
#  esr_ref_prefix            :string
#  homes_limit               :integer
#  iban                      :string
#  invoice_ref_strategy_type :string
#  invoice_ref_template      :string           default("%<prefix>s%<home_id>03d%<tenant_id>06d%<invoice_id>07d")
#  locale                    :string           default("de")
#  location                  :string
#  mail_from                 :string
#  name                      :string
#  notification_footer       :text
#  notifications_enabled     :boolean          default(TRUE)
#  payment_deadline          :integer          default(30), not null
#  ref_template              :string           default("%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s")
#  representative_address    :string
#  slug                      :string
#  smtp_settings             :jsonb
#  users_limit               :integer
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
