# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_conditions
#
#  id                :bigint           not null, primary key
#  compare_attribute :string
#  compare_operator  :string
#  compare_value     :string
#  group             :string
#  must_condition    :boolean          default(TRUE)
#  qualifiable_type  :string
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organisation_id   :bigint
#  qualifiable_id    :bigint
#

require 'rails_helper'

RSpec.describe BookingConditions::BookingState, type: :model do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:booking_condition) { described_class.new(compare_value:, organisation:, compare_operator:) }
    let(:organisation) { create(:organisation) }
    let(:booking) { create(:booking, organisation:, initial_state: :open_request, committed_request: false) }
    let(:compare_value) { 'open_request' }
    let(:compare_operator) { '=' }

    context 'with non matching state' do
      let(:booking) { create(:booking, organisation:) }

      it { is_expected.to be_falsy }
    end

    context 'with matching state' do
      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end

    context 'with previous matching state' do
      let(:compare_operator) { '>' }

      before do
        booking.update(committed_request: true)
        booking.apply_transitions(%i[provisional_request definitive_request])
      end

      it { expect(booking.booking_state.to_sym).to eq(:definitive_request) }
      it { is_expected.to be_truthy }
    end
  end
end
