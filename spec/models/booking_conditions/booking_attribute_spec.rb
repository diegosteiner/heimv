# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::BookingAttribute, type: :model do
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

    context 'with "nights" as attribute' do
      let(:compare_attribute) { :nights }
      let(:booking) do
        create(:booking, begins_at: 4.weeks.from_now, ends_at: 5.weeks.from_now, organisation:)
      end

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '3' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '8' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end

    context 'with "overnight_stays" as attribute' do
      let(:compare_attribute) { :overnight_stays }
      let(:booking) do
        create(:booking, approximate_headcount: 10, organisation:,
                         begins_at: 4.weeks.from_now, ends_at: 5.weeks.from_now)
      end

      it { is_expected.to be_falsy }
      it { expect(booking.overnight_stays).to eq(70) }

      context 'with non-matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '3' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :'>=' }
        let(:compare_value) { '60' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end

    context 'with "tenant_organisation" as attribute' do
      let(:compare_attribute) { :approximate_headcount }
      let(:booking) { create(:booking, approximate_headcount: 10, organisation:) }

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '5' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :'>=' }
        let(:compare_value) { '5' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end

    context 'with "tenant_organisation" as attribute' do
      let(:compare_attribute) { :tenant_organisation }
      let(:tenant_organisation) { 'test' }
      let(:booking) { create(:booking, organisation:, tenant_organisation:) }

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_value) { 'blabla' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_value) { tenant_organisation }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end
  end
end
