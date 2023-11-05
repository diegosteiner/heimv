# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Manage::TarifSerializer, type: :model do
  subject(:serialized) { described_class.render_as_hash(tarif) }

  let(:tarif) { create(:tarif) }

  it { is_expected.to include({ label: tarif.label }) }

  describe '#export' do
    subject(:serialized) { described_class.render_as_hash(tarif, view: :export) }

    it { expect(serialized.keys.map(&:to_s)).to include(*Import::Hash::TarifImporter.used_attributes) }
  end
end
