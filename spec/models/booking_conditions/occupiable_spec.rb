# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::Occupiable, type: :model do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:compare_value) { occupiable.id }
    let(:compare_attribute) { :occupiable }
    let(:compare_operator) { :'=' }
    let(:booking_condition) do
      described_class.new(compare_value:, compare_operator:, compare_attribute:, organisation:)
    end
    let(:booking) { create(:booking, organisation:) }
    let(:organisation) { create(:organisation) }
    let(:occupiable) { create(:home, organisation:) }

    before do
      qualifiable = double('Qualifiable')
      allow(qualifiable).to receive(:organisation).and_return(organisation)
      allow(booking_condition).to receive(:qualifiable).and_return(qualifiable)
    end

    it { expect(booking_condition).to be_valid }

    context 'without occupiable' do
      let(:compare_value) { nil }
      it { is_expected.to be_falsy }
      it { expect(booking_condition).not_to be_valid }
    end

    context 'without attribute' do
      let(:compare_attribute) { nil }
      it { expect(booking_condition).not_to be_valid }
    end

    context 'without operator' do
      let(:compare_operator) { nil }
      it { is_expected.to be_falsy }
      it { expect(booking_condition).not_to be_valid }
    end

    describe 'occupiable' do
      context 'with occupiable by id' do
        let(:booking) { create(:booking, organisation:, occupiables: [occupiable], home: occupiable) }

        it { is_expected.to be_truthy }
      end
    end
  end
end
