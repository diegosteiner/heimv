# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  data_digest_params :jsonb
#  label              :string
#  prefilter_params   :jsonb
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_data_digests_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe DataDigests::Payment, type: :model do
  subject(:data_digest) { create(:payment_data_digest) }
  let(:period) { data_digest.period(:ever) }

  before do
    create_list(:booking, 3, organisation: data_digest.organisation).map do |booking|
      invoice = create(:invoice, booking: booking)
      create(:payment, invoice: invoice, amount: invoice.amount)
    end
  end

  it { is_expected.to be_a(described_class) }

  describe '#digest' do
    subject(:periodic_data) { data_digest.digest(period) }

    it { is_expected.to be_a(DataDigest::PeriodicData) }
    its(:header) { is_expected.to eq(['Ref', 'Buchungsreferenz', 'Bezahlt am', 'Betrag', 'Mieter', 'Bemerkungen']) }
    it { expect(periodic_data.data.count).to be(3) }
  end

  describe '#csv' do
    it { expect(data_digest.digest(period, format: :csv)).to include('Betrag') }
  end

  describe '#pdf' do
    it { expect(data_digest.digest(period, format: :pdf)).not_to be_blank }
  end
end
