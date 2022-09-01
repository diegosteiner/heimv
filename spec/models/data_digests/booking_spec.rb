# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  columns_config     :jsonb
#  data_digest_params :jsonb
#  label              :string
#  prefilter_params   :jsonb
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           default(1), not null
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

RSpec.describe DataDigests::Booking, type: :model do
  let(:home) { create(:home) }
  let(:organisation) { home.organisation }
  let(:columns_config) { nil }
  let(:period) { DataDigest.period(:ever) }
  let(:data_digest) { create(:booking_data_digest, columns_config: columns_config, organisation: organisation) }
  let!(:bookings) do
    create_list(:booking, 3, organisation: organisation)
  end

  describe '#evaluate' do
    subject(:periodic_data) { data_digest.evaluate(period) }

    context 'with default columns' do
      it { is_expected.to be_a(DataDigest::PeriodicData) }
      it { expect(periodic_data.data.count).to be(3) }
      its(:header) do
        is_expected.to eq(['Buchungsreferenz', 'Heim', 'Beginn der Belegung', 'Ende der Belegung',
                           'Beschreibung des Mietzwecks', 'Nächte', 'Mieter', 'Adresse', 'Email', 'Telefon'])
      end
    end

    context 'with usage columns' do
      let(:tarif) { create(:tarif, home: home, price_per_unit: 10) }
      let!(:usages) do
        bookings.map do |booking|
          create(:usage, booking: booking, tarif: tarif, used_units: 1.5)
        end
      end
      let(:columns_config) do
        [
          {
            header: 'Ref',
            body: '{{ booking.ref }}'
          },
          {
            header: 'Usage Price',
            body: '{{ usage.price | currency }}',
            type: :usage,
            tarif_id: tarif.id
          }
        ]
      end

      it { is_expected.to be_a(DataDigest::PeriodicData) }
      it { expect(periodic_data.data.count).to be(3) }
      its(:header) { is_expected.to eq(['Ref', 'Usage Price']) }
      its(:rows) { is_expected.to eq(bookings.map { |booking| [booking.ref, 'CHF 15.00'] }) }
    end
  end

  describe '#csv' do
    it { expect(data_digest.evaluate(period).format(:csv)).to include('Heim') }
  end

  describe '#pdf' do
    it { expect(data_digest.evaluate(period).format(:pdf)).not_to be_blank }
  end
end
