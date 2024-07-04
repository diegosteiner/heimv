# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  account_address           :string
#  address                   :text
#  bcc                       :string
#  booking_flow_type         :string
#  booking_ref_template      :string           default("")
#  country_code              :string           default("CH"), not null
#  creditor_address          :text
#  currency                  :string           default("CHF")
#  default_payment_info_type :string
#  email                     :string
#  esr_beneficiary_account   :string
#  esr_ref_prefix            :string
#  homes_limit               :integer
#  iban                      :string
#  invoice_ref_template      :string           default("")
#  locale                    :string           default("de")
#  location                  :string
#  mail_from                 :string
#  name                      :string
#  notifications_enabled     :boolean          default(TRUE)
#  representative_address    :string
#  settings                  :jsonb
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

  describe '#settings' do
    subject(:settings) { organisation.settings }

    let(:settings_hash) { { test: 3600, feature_new_bookings: true } }
    let(:organisation) { build(:organisation, settings: settings_hash) }

    it do
      expect(settings.tenant_birth_date_required).to be(true)
    end
  end

  describe '#dup' do
    let(:organisation) { create(:organisation) }

    it do
      new_organisation = organisation.dup
      new_organisation.slug = 'new-test'
      expect(new_organisation).to be_valid
    end
  end
end
