# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Manage::OrganisationSerializer, type: :model do
  subject(:serialized) { described_class.render_as_hash(organisation) }
  let(:organisation) { create(:organisation) }

  it { is_expected.to include({ name: organisation.name }) }

  describe '#export' do
    subject(:serialized) { described_class.render_as_hash(organisation, view: :export) }
    it { expect(serialized.keys.map(&:to_s)).to include(*Import::Hash::OrganisationImporter.used_attributes) }
  end
end
