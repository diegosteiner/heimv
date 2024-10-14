# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id                        :bigint           not null, primary key
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
#  remarks                   :text
#  reservations_allowed      :boolean          default(TRUE)
#  salutation_form           :integer
#  search_cache              :text             not null
#  street_address            :string
#  zipcode                   :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  organisation_id           :bigint           not null
#
# Indexes
#
#  index_tenants_on_email                      (email)
#  index_tenants_on_email_and_organisation_id  (email,organisation_id) UNIQUE
#  index_tenants_on_organisation_id            (organisation_id)
#  index_tenants_on_search_cache               (search_cache)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
require 'rails_helper'

RSpec.describe Tenant, type: :model do
  let(:organisation) { create(:organisation) }
  let(:home) { create(:home, organisation:) }
  let(:tenant) { build(:tenant, organisation:) }

  describe '#save' do
    it { expect(tenant.save).to be true }
  end

  describe '#salutation' do
    let(:tenant) { build(:tenant, first_name: 'Peter', last_name: 'Muster', organisation:) }

    context 'with predefined_salutation_form' do
      before do
        organisation.settings.predefined_salutation_form = :informal_neutral
        organisation.save!
      end

      it 'uses the predefined form' do
        expect(tenant.salutation).to eq('Hallo Peter')
      end
    end

    context 'with predefined_salutation_form' do
      it 'does not use any salutation' do
        expect(tenant.salutation).to eq(nil)
      end
    end

    context 'with salutation_form set' do
      it 'uses the correct salutation form' do
        expected_salutations = {
          informal_neutral: 'Hallo Peter', informal_female: 'Liebe Peter', informal_male: 'Lieber Peter',
          formal_neutral: 'Guten Tag Peter Muster', formal_female: 'Sehr geehrte Frau Muster',
          formal_male: 'Sehr geehrter Herr Muster'
        }
        expected_salutations.each do |salutation_form, expected_salutation|
          tenant.update(salutation_form:)
          expect(tenant.salutation).to eq(expected_salutation)
        end
      end
    end
  end
end
