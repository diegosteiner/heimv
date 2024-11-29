# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_validations
#
#  id                 :bigint           not null, primary key
#  error_message_i18n :jsonb
#  ordinal            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_booking_validations_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
require 'rails_helper'

RSpec.describe BookingValidation, type: :model do
  let(:booking) { create(:booking, initial_state:, committed_request: false) }
  let(:organisation) { booking.organisation }
  let(:initial_state) { :provisional_request }
  let(:enabling_conditions) { [] }
  let(:validating_conditions) { [] }
  let(:booking_validation) { create(:booking_validation, organisation:, enabling_conditions:, validating_conditions:) }

  describe '#booking_valid?' do
    let(:validation_context) { :public_update }
    subject(:booking_valid) { booking_validation.booking_valid?(booking, validation_context:) }

    context 'with matching check_on' do
      before do
        expect(booking_validation).to receive(:enabled_by_condition?).with(booking).and_return(true)
        expect(booking_validation).to receive(:valid_by_condition?).with(booking).and_return(true)
      end

      it { is_expected.to be(true) }
    end

    context 'without matching check_on' do
      let(:validation_context) { :manage_update }
      before do
        booking_validation.update(check_on: %i[public_create public_update])
        expect(booking_validation).not_to receive(:enabled_by_condition?)
      end

      it { is_expected.to be(nil) }
    end

    context 'without enabling_condition' do
      before do
        expect(booking_validation).to receive(:enabled_by_condition?).with(booking).and_return(false)
        expect(booking_validation).not_to receive(:valid_by_condition?)
      end

      it { is_expected.to be(nil) }
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
