# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::Csv::TenantImporter, type: :model do
  let(:organisation) { create(:organisation) }
  let(:importer) { described_class.new(organisation) }
  let(:csv) do
    <<~ENDCSV
      "last_name","first_name","street_address","zipcode","city","country","email","phone_1","phone_2"
      "Muster","Peter","Teststrasse 24","8049","Zürich",,"test@example.com",,"044 444 44 44"
    ENDCSV
  end

  describe 'read' do
    let(:import) { importer.read(csv) }
    subject(:record) { import.first }

    it { is_expected.to be_valid }
    it do
      expect(record.first_name).to eq('Peter')
      expect(record.last_name).to eq('Muster')
      expect(record.street_address).to eq('Teststrasse 24')
      expect(record.zipcode).to eq('8049')
      expect(record.city).to eq('Zürich')
      expect(record.email).to eq('test@example.com')
    end
  end
end
