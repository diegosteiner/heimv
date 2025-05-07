# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::TenantAttribute do
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

    before do
      qualifiable = instance_double('Qualifiable') # rubocop:disable RSpec/VerifiedDoubleReference
      allow(qualifiable).to receive(:organisation).and_return(organisation)
      allow(booking_condition).to receive(:qualifiable).and_return(qualifiable)
    end

    context 'with "country_code" as attribute' do
      let(:compare_attribute) { :country_code }
      let(:booking) { create(:booking) }

      context 'with non-matching condition' do
        before { booking.tenant.update(country_code: :de) }

        let(:compare_operator) { :'=' }
        let(:compare_value) { 'FR' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        before { booking.tenant.update(country_code: :ch) }

        let(:compare_operator) { :'=' }
        let(:compare_value) { 'CH' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end
  end
end
