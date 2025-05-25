# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::OneOf do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:conditions) { [] }
    let(:booking_condition) { described_class.new(conditions:, organisation:) }
    let(:booking) { create(:booking, organisation:) }
    let(:organisation) { create(:organisation) }

    before do
      qualifiable = instance_double('Qualifiable') # rubocop:disable RSpec/VerifiedDoubleReference
      allow(qualifiable).to receive(:organisation).and_return(organisation)
      allow(booking_condition).to receive(:qualifiable).and_return(qualifiable)
    end

    context 'with two truthy conditions' do
      let(:conditions) do
        [
          BookingConditions::Always.new,
          BookingConditions::Always.new
        ]
      end

      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end

    context 'with two falsy conditions' do
      let(:conditions) do
        [
          BookingConditions::Never.new,
          BookingConditions::Never.new
        ]
      end

      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_falsy }
    end

    context 'with one truthy and one falsy conditions' do
      let(:conditions) do
        [
          BookingConditions::Always.new,
          BookingConditions::Never.new
        ]
      end

      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end

    context 'without conditions' do
      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end
  end
end
