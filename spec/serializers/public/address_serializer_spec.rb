# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Public::AddressSerializer, type: :model do
  subject { described_class.render_as_hash(address) }

  let(:address) { Address.new(address_hash) }
  let(:address_hash) do
    {
      recipient: 'Hans Muster', suffix: 'Abteilung Testing',
      representing: 'Organisation 2', street: 'Einbahnstrasse',
      street_nr: '12', postalcode: '8000', city: 'Zürich'
    }
  end

  it { is_expected.to include(address_hash) }
end
