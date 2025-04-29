# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                           :bigint           not null, primary key
#  account_address              :string
#  accounting_settings          :jsonb
#  address                      :text
#  bcc                          :string
#  booking_flow_type            :string
#  booking_ref_template         :string           default("%<home_ref>s%<year>04d%<month>02d%<day>02d%<same_day_alpha>s")
#  booking_state_settings       :jsonb
#  cors_origins                 :text
#  country_code                 :string           default("CH"), not null
#  creditor_address             :text
#  currency                     :string           default("CHF")
#  deadline_settings            :jsonb
#  default_payment_info_type    :string
#  email                        :string
#  esr_beneficiary_account      :string
#  esr_ref_prefix               :string
#  homes_limit                  :integer
#  iban                         :string
#  invoice_payment_ref_template :string           default("%<prefix>s%<tenant_sequence_number>06d%<sequence_year>04d%<sequence_number>05d")
#  invoice_ref_template         :string
#  locale                       :string
#  location                     :string
#  mail_from                    :string
#  name                         :string
#  nickname_label_i18n          :jsonb
#  notifications_enabled        :boolean          default(TRUE)
#  representative_address       :string
#  settings                     :jsonb
#  slug                         :string
#  smtp_settings                :jsonb
#  tenant_ref_template          :string
#  users_limit                  :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

require 'rails_helper'

RSpec.describe Organisation do
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
