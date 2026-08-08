# frozen_string_literal: true

# == Schema Information
#
# Table name: usages
#
#  id             :bigint           not null, primary key
#  committed      :boolean          default(FALSE)
#  details        :jsonb
#  price_per_unit :decimal(, )
#  quoted_units   :decimal(, )
#  remarks        :text
#  type           :string           not null
#  used_units     :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  booking_id     :uuid
#  tarif_id       :bigint
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

  describe '::build' do
    let(:booking) { create(:booking, organisation:, approximate_headcount: 12) }
    let(:built_usages) { described_class.build(booking, preselect: true) }
    let!(:tarif) do
      selecting_conditions = [
        BookingConditions::OccupancyDuration.new(compare_value: '1d',
                                                 compare_operator: :>),
        BookingConditions::BookingAttribute.new(compare_value: '10',
                                                compare_attribute: :approximate_headcount,
                                                compare_operator: :>)
      ]
      create(:tarif, organisation:, price_per_unit: 3.33, selecting_conditions:)
    end

    it do
      expect(built_usages.count).to be > 0
      usage = built_usages.first
      expect(usage.apply).to be true
      expect(usage.tarif).to eq(tarif)
    end

    it 'respects existing usages' do
      used_tarif = create(:tarif, organisation:, pin: true)
      tarifs = create_list(:tarif, 3, organisation:, pin: true)
      existing_usage = create(:usage, booking:, tarif: used_tarif)

      expect(built_usages).to(be_all { |actual| actual.is_a?(described_class) })
      tarif_ids = built_usages.map(&:tarif_id)

      expect(tarif_ids).to include(*tarifs.map(&:id))
      expect(tarif_ids).not_to include(existing_usage.tarif_id)
    end
  end

  describe '#prefill_units' do
    subject { usage.prefill_units }

    let(:booking) { create(:booking) }
    let(:usage) { tarif.build_usage(booking:) }
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

  describe '#minimum_price' do
    subject(:minimum_price) { usage.minimum_price }

    let(:booking) { create(:booking, organisation:) }
    let(:tarif) { create(:tarif, organisation:, price_per_unit: 10) }
    let(:usage) { tarif.build_usage(booking:) }

    it do
      tarif.update(minimum_mode: :usage_per_night, minimum: 24)
      is_expected.to eq(24 * 7 * 10)
    end

    it do
      tarif.update(minimum_mode: :usage_per_day, minimum: 24)
      is_expected.to eq(24 * 8 * 10)
    end

    it do
      tarif.update(minimum_mode: :usage_total, minimum: 71)
      is_expected.to eq(71 * 10)
    end

    it do
      tarif.update(minimum_mode: :price_per_night, minimum: 210)
      is_expected.to eq(210 * 7)
    end

    it do
      tarif.update(minimum_mode: :price_per_day, minimum: 210)
      is_expected.to eq(210 * 8)
    end

    it do
      tarif.update(minimum_mode: :price_total, minimum: 610)
      is_expected.to eq(610)
    end
  end

  describe '#save' do
    let(:booking) { create(:booking) }
    let(:usage) { build(:usage, booking:, tarif:) }

    it { expect(usage.save!).to be true }
  end

  describe '#billable_units' do
    let(:booking) { create(:booking) }
    let(:usage) { tarif.build_usage(booking:) }

    it do
      tarif.update(included_units: 5, included_units_mode: :usage_total)
      usage.used_units = 12
      usage.tarif.included_units_usage_total?
      expect(usage.billable_units).to eq(7)
    end

    it do
      tarif.update(included_units: 10, included_units_mode: :usage_per_night)
      usage.used_units = 0
      usage.tarif.included_units_usage_per_night?
      expect(usage.billable_units).to eq(0)
    end

    it do
      tarif.update(included_units: 5, included_units_mode: :usage_per_day)
      usage.used_units = 1000
      usage.tarif.included_units_usage_per_day?
      expect(usage.billable_units).to eq(960)
    end
  end
end
