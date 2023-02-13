# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digest_templates
#
#  id                      :bigint           not null, primary key
#  data                    :jsonb
#  period_from             :datetime
#  period_to               :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  data_digest_template_template_id :bigint           not null
#
# Indexes
#
#  index_data_digest_templates_on_data_digest_template_template_id  (data_digest_template_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (data_digest_template_template_id => data_digest_template_templates.id)
#

require 'rails_helper'

RSpec.describe DataDigestTemplates::Booking, type: :model do
  let(:home) { create(:home) }
  let(:organisation) { home.organisation }
  let(:columns_config) { nil }
  let(:data_digest_template) do
    create(:booking_data_digest_template, columns_config: columns_config, organisation: organisation)
  end
  let!(:bookings) do
    create_list(:booking, 3, organisation: organisation, homes: [home])
  end
  subject(:data_digest) { data_digest_template.data_digests.create }

  before do
    data_digest.crunch!
  end

  describe '#filter' do
    subject(:data_digest) { data_digest_template.data_digests.create(period_from: period_from, period_to: period_to) }
    let(:period_from) { Date.new(2023, 1, 1).beginning_of_day }
    let(:period_to) { Date.new(2023, 2, 1).beginning_of_day }
    let!(:bookings) do
      [
        (period_from - 2.weeks)..(period_from - 1.week), # no overlap
        (period_from - 1.week)..(period_from + 1.week),  # overlaps, but begins before
        (period_from + 1.week)..(period_to - 1.week),    # is completely contained
        (period_to - 1.week)..(period_to + 1.week),      # overlaps, and begins after
        (period_to + 1.week)..(period_to + 2.weeks)      # no overlap
      ].map { create(:booking, homes: [home], organisation: organisation, begins_at: _1.begin, ends_at: _1.end) }
    end

    it do
      expect(data_digest.records).to contain_exactly(*bookings[2..3])
    end
  end

  describe '#data' do
    context 'with default columns' do
      it { expect(data_digest).to be_a(DataDigest) }
      it { expect(data_digest.data.count).to be(3) }
      it do
        expect(data_digest.header).to eq ['Buchungsreferenz', 'Heim', 'Beginn der Belegung', 'Ende der Belegung',
                                          'Beschreibung des Mietzwecks', 'Nächte', 'Mieter', 'Adresse', 'Email',
                                          'Telefon']
      end
    end

    context 'with usage columns' do
      let(:tarif) { create(:tarif, organisation: organisation, price_per_unit: 10) }
      before do
        bookings.map do |booking|
          create(:usage, booking: booking, tarif: tarif, used_units: 1.5)
        end
        data_digest.crunch!
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

      it { expect(data_digest.data.count).to be(3) }
      it do
        expect(data_digest.header).to eq(['Ref', 'Usage Price'])
        expect(data_digest.data).to include(*bookings.map { |booking| [booking.ref, 'CHF 15.00'] })
      end
    end
  end

  describe '#csv' do
    it { expect(data_digest.format(:csv)).to include('Heim') }
  end

  describe '#pdf' do
    it { expect(data_digest.format(:pdf)).not_to be_blank }
  end
end
