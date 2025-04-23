# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_validations
#
#  id                 :bigint           not null, primary key
#  check_on           :integer          default(0), not null
#  error_message_i18n :jsonb            not null
#  ordinal            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
#

require 'rails_helper'

RSpec.describe BookingValidation do
  let(:booking) { create(:booking, initial_state:, committed_request: false) }
  let(:organisation) { booking.organisation }
  let(:initial_state) { :provisional_request }
  let(:enabling_conditions) { [] }
  let(:validating_conditions) { [] }
  let(:booking_validation) { create(:booking_validation, organisation:, enabling_conditions:, validating_conditions:) }

  describe '#booking_valid?' do
    subject(:booking_valid) { booking_validation.booking_valid?(booking, validation_context:) }

    let(:validation_context) { :public_update }

    before do
      allow(booking_validation).to receive(:enabled_by_condition?).with(booking).and_return(true)
      allow(booking_validation).to receive(:valid_by_condition?).with(booking).and_return(true)
    end

    context 'with matching check_on' do
      it 'checks the condition' do
        is_expected.to be(true)
        expect(booking_validation).to have_received(:enabled_by_condition?)
        expect(booking_validation).to have_received(:valid_by_condition?)
      end
    end

    context 'without matching check_on' do
      let(:validation_context) { :manage_update }

      before do
        booking_validation.update(check_on: %i[public_create public_update])
      end

      it 'checks the condition' do
        is_expected.to be(true)
        expect(booking_validation).not_to have_received(:enabled_by_condition?)
        expect(booking_validation).to have_received(:valid_by_condition?)
      end
    end

    context 'without enabling_condition' do
      before do
        allow(booking_validation).to receive(:enabled_by_condition?).with(booking).and_return(false)
      end

      it 'checks the condition' do
        is_expected.to be(true)
        expect(booking_validation).to have_received(:enabled_by_condition?)
        expect(booking_validation).not_to have_received(:valid_by_condition?)
      end
    end
  end

  describe '#enabled_by_condition?' do
    subject(:enabled_by_condition) { booking_validation.enabled_by_condition?(booking) }

    let(:enabling_conditions) { [BookingConditions::AlwaysApply.new] }

    it { is_expected.to be(true) }
  end

  describe '#valid_by_condition?' do
    subject(:valid_by_condition) { booking_validation.enabled_by_condition?(booking) }

    let(:validating_conditions) { [BookingConditions::AlwaysApply.new] }

    it { is_expected.to be(true) }
  end
end
