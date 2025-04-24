# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComparableDatetime, type: :model do
  describe '::from_value' do
    subject(:compare_value) { described_class.from_value(value) }

    context 'with date' do
      let(:value) { Date.new(2024, 9, 2) }

      it 'uses date' do
        expect(compare_value.year).to eq(2024)
        expect(compare_value.month).to eq(9)
        expect(compare_value.day).to eq(2)
        expect(compare_value.hour).to be_falsy
        expect(compare_value.minute).to be_falsy
        expect(compare_value.weekday).to eq(1)
      end
    end

    context 'with datetime' do
      let(:value) { Time.zone.local(2024, 9, 2, 12, 55) }

      it 'uses datetime in utc' do
        expect(compare_value.year).to eq(2024)
        expect(compare_value.month).to eq(9)
        expect(compare_value.day).to eq(2)
        expect(compare_value.hour).to eq(12)
        expect(compare_value.minute).to eq(55)
        expect(compare_value.weekday).to eq(1)
      end
    end

    context 'with string' do
      it 'parses the date string' do
        expect(described_class.from_string('')).to eq(nil) # rubocop:disable RSpec/BeEq
        expect(described_class.from_string('2024-*-*')).to eq(described_class.from_value(year: 2024))
        expect(described_class.from_string('*-09-*')).to eq(described_class.from_value(month: 9))
        expect(described_class.from_string('*-*-3')).to eq(described_class.from_value(day: 3))
      end

      it 'parses the weekday string' do
        expect(described_class.from_string('W1')).to eq(described_class.from_value(weekday: 1))
        expect(described_class.from_string('W9')).to eq(described_class.from_value(weekday: 2))
      end

      it 'parses the time string' do
        expect(described_class.from_string('T10:*')).to eq(described_class.from_value(hour: 10))
        expect(described_class.from_string('T*:55')).to eq(described_class.from_value(minute: 55))
      end

      it 'parses the all parts together' do
        expect(described_class.from_string('2024-09-3W3T10:55')).to eq(
          described_class.from_value({ year: 2024, month: 9, day: 3, weekday: 3, hour: 10, minute: 55 })
        )
        expect(described_class.from_string('2024-09-3T10:55')).to eq(
          described_class.from_value({ year: 2024, month: 9, day: 3, weekday: nil, hour: 10, minute: 55 })
        )
        expect(described_class.from_string('*-*-*W*T*:*')).to eq(
          described_class.from_value({ year: nil, month: nil, day: nil, weekday: nil, hour: nil, minute: nil })
        )
      end
    end

    context 'with overflowing values' do
      let(:value) { { month: 13, day: 32, weekday: 8, hour: 24, minute: 65 } }

      it 'wraps integer values around' do
        expect(compare_value.month).to eq(1) # january
        expect(compare_value.day).to eq(1) # 1. of month
        expect(compare_value.weekday).to eq(1) # 1. of month
        expect(compare_value.hour).to eq(0) # midnight
        expect(compare_value.minute).to eq(5)
      end
    end

    context 'with minimum values' do
      let(:value) { { month: 1, day: 1, weekday: 0, hour: 0, minute: 0 } }

      it 'keeps minimum integer values' do
        expect(compare_value.month).to eq(1) # january
        expect(compare_value.day).to eq(1) # 1. of month
        expect(compare_value.weekday).to eq(7) # 1. of month
        expect(compare_value.hour).to eq(0) # midnight
        expect(compare_value.minute).to eq(0)
      end
    end
  end

  describe '#<=>' do
    context 'with simple comparisons' do
      let(:compare_value) { described_class.from_value(Time.zone.local(2024, 9, 3, 12, 55)) }

      it 'compares the year' do
        expect(compare_value).to be >= described_class.from_value(year: 2023)
        expect(compare_value).not_to be >= described_class.from_value(year: 2025)
        expect(compare_value).to be >= described_class.from_value(year: 2023, month: 10)
      end

      it 'compares the month' do
        expect(compare_value).to be >= described_class.from_value(month: 8)
        expect(compare_value).not_to be >= described_class.from_value(month: 10)
        expect(compare_value).to be >= described_class.from_value(month: 8, day: 4)
      end

      it 'compares the day' do
        expect(compare_value).to be >= described_class.from_value(day: 2)
        expect(compare_value).not_to be >= described_class.from_value(day: 4)
        expect(compare_value).to be >= described_class.from_value(day: 1, weekday: 4)
      end

      it 'compares the weekday' do
        expect(compare_value).to be >= described_class.from_value(weekday: 1)
        expect(compare_value).not_to be >= described_class.from_value(weekday: 3)
        expect(compare_value).to be >= described_class.from_value(weekday: 1, hour: 14)
      end

      it 'compares the hour' do
        expect(compare_value).to be >= described_class.from_value(hour: 9)
        expect(compare_value).not_to be >= described_class.from_value(hour: 14)
        expect(compare_value).to be >= described_class.from_value(hour: 7, minute: 58)
      end

      it 'compares the minute' do
        expect(compare_value).to be >= described_class.from_value(minute: 50)
        expect(compare_value).not_to be >= described_class.from_value(minute: 58)
      end
    end
  end
end
