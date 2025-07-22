# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganisationSettings do
  subject(:settings) { organisation.settings }

  let(:organisation) { create(:organisation) }

  before { organisation.settings = {} }

  describe 'valid?' do
    it { is_expected.to be_valid }
  end
end
