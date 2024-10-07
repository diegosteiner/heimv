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

  describe '#save' do
    let(:tenant) { build(:tenant, organisation:) }

    it { expect(tenant.save).to be true }
  end
end
