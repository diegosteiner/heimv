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
# Indexes
#
#  index_booking_conditions_on_organisation_id                      (organisation_id)
#  index_booking_conditions_on_qualifiable                          (qualifiable_id,qualifiable_type,group)
#  index_booking_conditions_on_qualifiable_id_and_qualifiable_type  (qualifiable_id,qualifiable_type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe BookingConditions::BookingAttribute, type: :model do
  describe '#evaluate' do
    subject { booking_condition.evaluate(booking) }
    let(:compare_value) { nil }
    let(:compare_operator) { :'=' }
    let(:compare_attribute) { nil }
    let(:organisation) { create(:organisation) }
    let(:booking_condition) do
      described_class.new(compare_value: compare_value, organisation: organisation,
                          compare_operator: compare_operator, compare_attribute: compare_attribute)
    end

    context 'with "nights" as attribute' do
      let(:compare_attribute) { :nights }
      let(:booking) do
        create(:booking, begins_at: 4.weeks.from_now, ends_at: 5.weeks.from_now, organisation: organisation)
      end

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '3' }
        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '8' }
        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end

    context 'with "overnight_stays" as attribute' do
      let(:compare_attribute) { :overnight_stays }
      let(:booking) do
        create(:booking, approximate_headcount: 10, organisation: organisation,
                         begins_at: 4.weeks.from_now, ends_at: 5.weeks.from_now)
      end

      it { is_expected.to be_falsy }
      it { expect(booking.overnight_stays).to eq(70) }

      context 'with non-matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '3' }
        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :'>=' }
        let(:compare_value) { '60' }
        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end

    context 'with "tenant_organisation" as attribute' do
      let(:compare_attribute) { :approximate_headcount }
      let(:booking) { create(:booking, approximate_headcount: 10, organisation: organisation) }

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '5' }
        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :'>=' }
        let(:compare_value) { '5' }
        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end

    context 'with "tenant_organisation" as attribute' do
      let(:compare_attribute) { :tenant_organisation }
      let(:tenant_organisation) { 'test' }
      let(:booking) { create(:booking, organisation: organisation, tenant_organisation: tenant_organisation) }

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_value) { 'blabla' }
        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_value) { tenant_organisation }
        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end
  end
end
