# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Manage::OrganisationSerializer, type: :model do
  subject { described_class.render_as_hash(organisation, view: :export) }
  let(:organisation) { create(:organisation) }

  it { is_expected.to include({ name: organisation.name }) }
end
