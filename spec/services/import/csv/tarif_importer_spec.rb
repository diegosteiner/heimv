# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::Csv::TarifImporter, type: :model do
  let(:organisation) { create(:organisation) }
  let(:header_mapping) do
    %w[tarif.ordinal tarif.label tarif.type tarif.tarif_group tarif.unit tarif.price tarif.associated_types]
  end
  let(:importer) { described_class.new(organisation, csv: { headers: header_mapping }) }
  let(:csv) do
    <<~ENDCSV
      "ordinal","label","type","tarif_group","unit","price","associated_types"
      11,"Tagesmiete auswärtige Pfadi","Tarifs::Flat","Tagesmiete",,150,
      12,"Tagesmiete Dritte / Privat","Tarifs::Flat","Tagesmiete",,380,
      ,,,,,,
      21,"Übernachtungtarif auswärtige Pfadi","Tarifs::OvernightStay","Übernachtungsmiete","Übernachtung",11,
      22,"Übernachtungtarif Schulen / J+S Lager","Tarifs::OvernightStay","Übernachtungsmiete","Übernachtung",14,
      23,"Übernachtungtarif Dritte / Privat","Tarifs::OvernightStay","Übernachtungsmiete","Übernachtung",18,
      41,"Mindestbelegung auswärtige Pfadi","Tarifs::Flat","Mindestbelegung",,220,
      42,"Mindestbelegung Schulen / J+S Lager","Tarifs::Flat","Mindestbelegung",,280,
      43,"Mindestbelegung Dritte / Privat","Tarifs::Flat","Mindestbelegung",,450,
      24,"Beherbergungstaxe Ü16 (im Mietpreis inbegriffen)","Tarifs::OvernightStay","Übernachtungsmiete","Übernachtung",0,
      51,"Strom / Wasser Tarifs::Flat (Sommer)","Tarifs::Amount","Nebenkosten","Tag",20,
    ENDCSV
  end

  describe '#parse' do
    subject(:record) { import.records.first }

    let(:import) { importer.parse(csv) }

    it { expect(import.records.compact.count).to eq(10) }
    it { is_expected.to be_valid }
    it { is_expected.to be_a(Tarifs::Flat) }

    it do
      expect(record.organisation).to eq(organisation)
      expect(record.ordinal).to eq(11)
      expect(record.label).to eq('Tagesmiete auswärtige Pfadi')
      expect(record.tarif_group).to eq('Tagesmiete')
      expect(record.price_per_unit).to eq(150.0)
    end
  end
end
