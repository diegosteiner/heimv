# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransitionBookingStatesJob, type: :job do
  describe '#perform' do
    subject { described_class.perform_now }

    it { is_expected.to eq(true) }
  end
end
