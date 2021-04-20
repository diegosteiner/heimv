# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::Csv::BookingImporter, type: :model do
  let(:organisation) { create(:organisation) }
  let!(:booking_purpose) { create(:booking_purpose, organisation: organisation, key: 'youth_camp') }
  let(:home) { create(:home, organisation: organisation) }
  let(:importer) { described_class.new(home) }
  let(:csv) do
    <<~ENDCSV
      "begins_at","ends_at","purpose","ref","organisation","email","phone","remarks"
      2021-05-01T10:00:00,2021-05-09T18:15:00,"youth_camp","0815","Pfadi Test","test@example.com","079 1234 67 88","Bemerkung"
    ENDCSV
  end

  describe 'read' do
    let(:import) { importer.read(csv) }
    subject(:record) { import.first }

    it { is_expected.to be_valid }
    it do
      expect(record.occupancy.begins_at).to eq(Time.zone.local(2021, 5, 1, 10, 0, 0))
      expect(record.occupancy.ends_at).to eq(Time.zone.local(2021, 5, 9, 18, 15, 0))
      expect(record.purpose).to eq(booking_purpose)
      expect(record.ref).to eq('0815')
      expect(record.remarks).to eq('Bemerkung')
      expect(record.notifications_enabled).to be false
      # expect(record.booking_state).to be_a(BookingStates::Upcoming)
    end
  end
end
