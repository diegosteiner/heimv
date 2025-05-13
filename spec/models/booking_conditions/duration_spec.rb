# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::Duration do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:compare_value) { nil }
    let(:compare_operator) { :'=' }
    let(:compare_attribute) { nil }
    let(:organisation) { create(:organisation) }
    let(:booking_condition) do
      described_class.new(compare_value:, organisation:, compare_operator:, compare_attribute:)
    end

    before do
      qualifiable = instance_double('Qualifiable') # rubocop:disable RSpec/VerifiedDoubleReference
      allow(qualifiable).to receive(:organisation).and_return(organisation)
      allow(booking_condition).to receive(:qualifiable).and_return(qualifiable)
    end

    context 'with "now_to_begins_at" as attribute' do
      let(:compare_attribute) { :now_to_begins_at }
      let(:begins_at) { nil }
      let(:ends_at) { begins_at + 1.week }
      let(:booking) { create(:booking, begins_at:, ends_at:, organisation:) }

      context 'when booking begins in 3 months' do
        let(:begins_at) { 3.months.from_now }

        context 'with < garbage' do
          let(:compare_operator) { :< }
          let(:compare_value) { 'garbage' }

          it { expect(booking_condition).not_to be_valid }
        end

        context 'with < P1M' do
          let(:compare_operator) { :< }
          let(:compare_value) { 'P1M' }

          it { expect(booking_condition).to be_valid }
          it { is_expected.to be_falsy }
        end

        context 'with > P1M' do
          let(:compare_operator) { :> }
          let(:compare_value) { 'P1M' }

          it { expect(booking_condition).to be_valid }
          it { is_expected.to be_truthy }
        end
      end
    end

    context 'with "now_to_ends_at" as attribute' do
      let(:compare_attribute) { :now_to_ends_at }
      let(:begins_at) { nil }
      let(:ends_at) { begins_at + 1.week }
      let(:booking) { create(:booking, begins_at:, ends_at:, organisation:) }

      context 'when booking ended 3 months ago' do
        let(:begins_at) { 3.months.ago - 1.week }

        context 'with < -P1M' do
          let(:compare_operator) { :< }
          let(:compare_value) { '-P1M2DT12H' }

          it { expect(booking_condition).to be_valid }
          it { is_expected.to be_truthy }
        end

        context 'with > -P1M' do
          let(:compare_operator) { :> }
          let(:compare_value) { 'P1MT12M' }

          it { expect(booking_condition).to be_valid }
          it { is_expected.to be_falsy }
        end
      end
    end

    context 'with "begins_at_to_ends_at" as attribute' do
      let(:compare_attribute) { :now_to_ends_at }
      let(:begins_at) { nil }
      let(:ends_at) { begins_at + 1.week }
      let(:booking) { create(:booking, begins_at:, ends_at:, organisation:) }

      context 'when booking is one day long' do
        let(:begins_at) { 3.months.from_now }
        let(:ends_at) { begins_at + 1.day }

        context 'with = P1D' do
          let(:compare_operator) { :'=' }
          let(:compare_value) { 'P1D' }

          it { expect(booking_condition).to be_valid }
          it { is_expected.to be_falsy }
        end

        context 'with != P1D' do
          let(:compare_operator) { :!= }
          let(:compare_value) { 'P1M' }

          it { expect(booking_condition).to be_valid }
          it { is_expected.to be_truthy }
        end
      end
    end
  end
end
