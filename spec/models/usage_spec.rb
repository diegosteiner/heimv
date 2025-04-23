# frozen_string_literal: true

# == Schema Information
#
# Table name: usages
#
#  id                  :bigint           not null, primary key
#  committed           :boolean          default(FALSE)
#  details             :jsonb
#  presumed_used_units :decimal(, )
#  price_per_unit      :decimal(, )
#  remarks             :text
#  used_units          :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid
#  tarif_id            :bigint
#

require 'rails_helper'

RSpec.describe Usage do
  let(:organisation) { create(:organisation) }
  let(:tarif) { create(:tarif, organisation:, price_per_unit: 3.33) }

  describe '#price' do
    subject { usage.price }

    let(:usage) { build(:usage, tarif:, used_units: 2) }

    it { is_expected.to eq(6.65) }
  end

  describe Usage::Factory do
    describe 'build' do
      subject(:factory) { described_class.new(booking) }

      let(:booking) { create(:booking, organisation:, approximate_headcount: 12) }

      let(:usages) { factory.build(preselect: true) }

      before do
        BookingConditions::OccupancyDuration.create(qualifiable: tarif, group: :selecting, compare_value: '1d',
                                                    compare_operator: :>)
        BookingConditions::BookingAttribute.create(qualifiable: tarif, group: :selecting, compare_value: '10',
                                                   compare_attribute: :approximate_headcount, compare_operator: :>)
        BookingConditions::BookingAttribute.create(qualifiable: tarif, group: :selecting, compare_value: 'test',
                                                   compare_attribute: :tenant_organisation, must_condition: false)
      end

      it do
        expect(usages.count).to be > 0
        usage = usages.first
        expect(usage.apply).to be true
        expect(usage.tarif).to eq(tarif)
      end
    end
  end

  describe '#presumed_units' do
    subject { usage.presumed_units }

    let(:booking) { create(:booking) }
    let(:usage) { build(:usage, booking:, tarif:) }
    let(:booking_question) { create(:booking_question, organisation:) }
    let(:booking_question_response) do
      booking_question.booking_question_responses.create(booking:, value: 25)
    end

    context 'with no prefill method and no booking question' do
      it { is_expected.to be_nil }
    end

    context 'with only prefill method' do
      let(:tarif) { organisation.tarifs.create(prefill_usage_method: :nights) }

      it { is_expected.to eq(booking.nights) }
    end

    context 'with only booking queston' do
      let(:tarif) { organisation.tarifs.create(prefill_usage_booking_question: booking_question) }

      before { booking_question_response }

      it { is_expected.to eq(25) }
    end

    context 'with both prefill method and booking queston' do
      let(:tarif) do
        organisation.tarifs.create(prefill_usage_booking_question: booking_question, prefill_usage_method: :nights)
      end

      before { booking_question_response }

      it { is_expected.to eq(25 * booking.nights) }
    end
  end

  describe '#save' do
    let(:booking) { create(:booking) }
    let(:usage) { build(:usage, booking:, tarif:) }

    it { expect(usage.save!).to be true }
  end
end
