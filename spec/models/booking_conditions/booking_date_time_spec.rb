# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::BookingDateTime, type: :model do
  let(:organisation) { create(:organisation) }

  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:compare_value) { nil }
    let(:compare_operator) { :'=' }
    let(:compare_attribute) { nil }
    let(:booking_condition) do
      described_class.new(compare_value:, organisation:, compare_operator:, compare_attribute:)
    end

    before do
      qualifiable = double('Qualifiable')
      allow(qualifiable).to receive(:organisation).and_return(organisation)
      allow(booking_condition).to receive(:qualifiable).and_return(qualifiable)
    end

    context 'with "now" as attribute' do
      let(:compare_attribute) { :now }
      let(:booking) do
        create(:booking, begins_at: 4.weeks.from_now, ends_at: 5.weeks.from_now, organisation:)
      end

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '2024-1-1' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :> }
        let(:compare_value) { '2024-1-1' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end
  end
end
