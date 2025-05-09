# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id                        :bigint           not null, primary key
#  accounting_account_nr     :string
#  address_addon             :string
#  birth_date                :date
#  bookings_without_contract :boolean          default(FALSE)
#  bookings_without_invoice  :boolean          default(FALSE)
#  city                      :string
#  country_code              :string           default("CH")
#  email                     :string
#  email_verified            :boolean          default(FALSE)
#  first_name                :string
#  import_data               :jsonb
#  last_name                 :string
#  locale                    :string
#  nickname                  :string
#  phone                     :text
#  ref                       :string
#  remarks                   :text
#  reservations_allowed      :boolean          default(TRUE)
#  salutation_form           :integer
#  search_cache              :text             not null
#  sequence_number           :integer
#  street_address            :string
#  zipcode                   :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  organisation_id           :bigint           not null
#
require 'rails_helper'

RSpec.describe Tenant do
  let(:organisation) { create(:organisation) }
  let(:home) { create(:home, organisation:) }
  let(:tenant) { build(:tenant, first_name: 'Peter', last_name: 'Muster', organisation:) }

  describe '#save' do
    it { expect(tenant.save).to be true }
  end

  describe '#salutation' do
    # context 'with predefined_salutation_form' do
    # before do
    #   organisation.settings.predefined_salutation_form = :informal_neutral
    #   organisation.save!
    # end
    # end

    it 'uses the predefined form' do
      expect(tenant.salutation).to eq('Hallo Peter')
    end
    # context 'with predefined_salutation_form' do
    #   it 'does not use any salutation' do
    #     expect(tenant.salutation).to eq(nil)
    #   end
    # end
  end

  describe '#salutations' do
    it 'uses the correct salutations forms and names' do
      expect(tenant.salutations).to eq({
                                         informal_neutral: 'Hallo Peter',
                                         informal_female: 'Liebe Peter',
                                         informal_male: 'Lieber Peter',
                                         formal_neutral: 'Guten Tag Peter Muster',
                                         formal_female: 'Sehr geehrte Frau Muster',
                                         formal_male: 'Sehr geehrter Herr Muster'
                                       })
    end
  end
end
