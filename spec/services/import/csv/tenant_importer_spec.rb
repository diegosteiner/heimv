# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::Csv::TenantImporter, type: :model do
  let(:organisation) { create(:organisation) }
  let(:header_mapping) do
    %w[tenant.last_name tenant.first_name tenant.street_address tenant.zipcode
       tenant.city tenant.country_code tenant.email tenant.phone_1 tenant.phone_2]
  end
  let(:importer) { described_class.new(organisation, csv: { headers: header_mapping }) }
  let(:csv) do
    <<~ENDCSV
      "Nachname","Vorname","Adresse","PLZ","Ort","Land","E-Mail","Mobiltelefon","Festnetz"
      "Muster","Peter","Teststrasse 24","8049","Zürich",,"test@heimv.test",,"044 444 44 44"
    ENDCSV
  end

  describe '#parse' do
    subject(:record) { import.records.first }

    let(:import) { importer.parse(csv) }

    it { is_expected.to be_valid }

    it do
      expect(record.first_name).to eq('Peter')
      expect(record.last_name).to eq('Muster')
      expect(record.street_address).to eq('Teststrasse 24')
      expect(record.zipcode).to eq('8049')
      expect(record.city).to eq('Zürich')
      expect(record.email).to eq('test@heimv.test')
    end
  end
end
