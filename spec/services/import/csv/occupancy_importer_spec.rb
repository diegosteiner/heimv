# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::Csv::OccupancyImporter, type: :model do
  let(:organisation) { create(:organisation) }
  let(:occupiable) { create(:occupiable, organisation: organisation) }
  let(:options) { {} }
  let(:importer) { described_class.new(organisation, csv: { headers: header_mapping }, initial_state: initial_state) }

  describe '#parse' do
    let(:result) { importer.parse(csv, **options) }
    let(:initial_state) { :open_request }
    let(:header_mapping) do
      %w[occupancy.begins_at occupancy.ends_at occupancy.occupancy_type occupancy.remarks occupancy.occupiable_id]
    end
    let(:csv) do
      <<~ENDCSV
        "begins_at","ends_at","occupancy_type","remarks","occupiable"
        2021-05-01T10:00:00,2021-05-09T18:15:00,"closed","Bemerkung","#{occupiable.id}"
      ENDCSV
    end

    it { result.records.each { |record| expect(record).to be_valid } }
    it { expect(result).to be_ok }

    it do
      occupancy = result.records.first
      expect(occupancy.begins_at).to eq(Time.zone.local(2021, 5, 1, 10, 0, 0))
      expect(occupancy.ends_at).to eq(Time.zone.local(2021, 5, 9, 18, 15, 0))
      expect(occupancy.occupancy_type).to eq('closed')
      expect(occupancy.remarks).to eq('Bemerkung')
    end
  end
end
