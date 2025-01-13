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

RSpec.describe BookingConditions::TenantAttribute, type: :model do
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
