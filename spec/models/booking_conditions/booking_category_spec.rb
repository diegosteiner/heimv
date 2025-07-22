# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::BookingCategory do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:compare_value) { '' }
    let(:booking_condition) { described_class.new(compare_value:, organisation:) }
    let(:booking) { create(:booking, organisation:) }
    let(:organisation) { create(:organisation) }
    let(:booking_category) { create(:booking_category, organisation:, key: 'test') }

    before do
      qualifiable = instance_double('Qualifiable') # rubocop:disable RSpec/VerifiedDoubleReference
      allow(qualifiable).to receive(:organisation).and_return(organisation)
      allow(booking_condition).to receive(:qualifiable).and_return(qualifiable)
    end

    context 'without category' do
      it { is_expected.to be_falsy }
      it { expect(booking_condition).not_to be_valid }
    end

    context 'with category by key' do
      let(:compare_value) { booking_category.key }
      let(:booking) { create(:booking, organisation:, category: booking_category) }

      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end

    context 'with category by id' do
      let(:compare_value) { booking_category.id }
      let(:booking) { create(:booking, organisation:, category: booking_category) }

      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end
  end
end
