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

RSpec.describe BookingConditions::BookingCategory, type: :model do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:compare_value) { '' }
    let(:booking_condition) { described_class.new(compare_value:, organisation:) }
    let(:booking) { create(:booking, organisation:) }
    let(:organisation) { create(:organisation) }
    let(:booking_category) { create(:booking_category, organisation:, key: 'test') }

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
