# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::OccupancyDuration do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:compare_value) { nil }
    let(:compare_operator) { :'=' }
    let(:compare_attribute) { nil }
    let(:organisation) { create(:organisation) }
    let(:booking_condition) do
      described_class.new(compare_value:, organisation:,
                          compare_operator:, compare_attribute:)
    end
    let(:booking) do
      create(:booking, begins_at: 4.weeks.from_now, ends_at: 5.weeks.from_now, organisation:)
    end

    before do
      qualifiable = instance_double('Qualifiable') # rubocop:disable RSpec/VerifiedDoubleReference
      allow(qualifiable).to receive(:organisation).and_return(organisation)
      allow(booking_condition).to receive(:qualifiable).and_return(qualifiable)
    end

    it { is_expected.to be_falsy }

    context 'with non-matching condition' do
      let(:compare_operator) { :< }
      let(:compare_value) { '8h' }

      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_falsy }
    end

    context 'with matching condition' do
      let(:compare_operator) { :> }
      let(:compare_value) { '1d' }

      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end
  end
end
