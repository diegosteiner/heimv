# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::Csv::OccupancyImporter, type: :model do
  let(:organisation) { create(:organisation) }
  let(:options) { {} }
  let!(:booking_category) { create(:booking_category, organisation: organisation, key: 'youth_camp') }
  let(:home) { create(:home, organisation: organisation) }
  let(:importer) { described_class.new(home, csv: { headers: header_mapping }, initial_state: initial_state) }

  describe '#parse' do
    let(:result) { importer.parse(csv, **options) }

    context 'with custom csv' do
      let(:initial_state) { :open_request }
      let(:header_mapping) do
        %w[occupancy.begins_at occupancy.ends_at booking.category booking.ref booking.tenant_organisation
           tenant.email tenant.phone booking.remarks]
      end
      let(:csv) do
        <<~ENDCSV
          "begins_at","ends_at","purpose","ref","organisation","email","phone","remarks"
          2021-05-01T10:00:00,2021-05-09T18:15:00,"youth_camp","0815","Pfadi Test","test@example.com","079 1234 67 88","Bemerkung"
        ENDCSV
      end

      it { result.records.each { |record| expect(record).to be_valid } }
      it { expect(result).to be_ok }

      it do
        occupancy = result.records.first
        expect(occupancy.begins_at).to eq(Time.zone.local(2021, 5, 1, 10, 0, 0))
        expect(occupancy.ends_at).to eq(Time.zone.local(2021, 5, 9, 18, 15, 0))
      end

      it do
        booking = result.records.first.booking
        expect(booking.category).to eq(booking_category)
        expect(booking.ref).to eq('0815')
        expect(booking.remarks).to eq('Bemerkung')
        expect(booking.notifications_enabled).to be false
        expect(booking.booking_state).to be_a(BookingStates::OpenRequest)
      end
    end

    context 'with pfadiheime.ch csv' do
      let(:initial_state) { :provisional_request }
      let(:header_mapping) { Import::PfadiheimeImporter::OCCUPANCY_HEADER_MAPPING }
      let(:csv) do
        <<~ENDCSV
          id,cottage_id,user_id,start_date,end_date,remarks,reservation_type,created_at,updated_at,contact_email,occupancy_type,purpose,headcount,birthdate,tenant_organisation,address_line1,address_line2,address_line3,zip,place,phone
          118531,281,,2019-06-20 12:00:00 +0200,2019-06-20 22:00:00 +0200,,definitely_reserved,2018-06-11 18:53:07 +0200,2021-05-04 16:57:13 +0200,tenant22@heimv.local,,Test,,,,,"Peter Muster",,,8000,Zürich,
          118532,281,,2020-06-20 12:00:00 +0200,2020-06-20 22:00:00 +0200,,provisionally_reserved,2018-06-11 18:53:07 +0200,2021-05-04 16:57:13 +0200,tenant22@heimv.local,,Test,,12,,,"Peter Muster",,,8000,Zürich,
          118533,281,,2019-06-06 08:00:00 +0200,2019-06-06 22:00:00 +0200,,closed,,,,,,,,,,,,,,,
        ENDCSV
      end

      it {
        expect(result.records).to all(be_valid)
      }

      it do
        occupancy = result.records.first
        expect(occupancy.begins_at).to eq(Time.zone.local(2019, 6, 20, 12, 0, 0))
        expect(occupancy.ends_at).to eq(Time.zone.local(2019, 6, 20, 22, 0, 0))
      end

      it do
        booking = result.records.first.booking
        expect(booking.tenant.first_name).to eq('Peter')
        expect(booking.tenant.last_name).to eq('Muster')
        expect(booking.tenant.email).to eq('tenant22@heimv.local')
        expect(booking.booking_state).to be_a(BookingStates::DefinitiveRequest)
        expect(booking.committed_request).to be_truthy
        expect(booking).to be_tentative
      end

      it do
        booking = result.records.second.booking
        expect(booking.booking_state).to be_a(BookingStates::ProvisionalRequest)
        expect(booking.approximate_headcount).to eq 12
        expect(booking.email).to eq('tenant22@heimv.local')
        expect(booking.committed_request).to be_falsy
        expect(booking).to be_tentative
      end

      it do
        occupancy = result.records.last
        expect(occupancy.begins_at).to eq(Time.zone.local(2019, 6, 6, 8, 0, 0))
        expect(occupancy.ends_at).to eq(Time.zone.local(2019, 6, 6, 22, 0, 0))
        expect(occupancy.closed?).to be true
        expect(occupancy.booking).to be nil
      end
    end
  end
end
