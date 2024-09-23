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

RSpec.describe BookingConditions::BookingDateTime, type: :model do
  let(:organisation) { create(:organisation) }

  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:compare_value) { nil }
    let(:compare_operator) { :'=' }
    let(:compare_attribute) { nil }
    let(:booking_condition) do
      described_class.new(compare_value:, organisation:, compare_operator:, compare_attribute:)
    end

    context 'with "now" as attribute' do
      let(:compare_attribute) { :now }
      let(:booking) do
        create(:booking, begins_at: 4.weeks.from_now, ends_at: 5.weeks.from_now, organisation:)
      end

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_operator) { :< }
        let(:compare_value) { '2024-1-1' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :> }
        let(:compare_value) { '2024-1-1' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#paradox_conditions' do
    context 'with paradox conditions in same context' do
      let(:qualifiable) { BookingValidation.create(organisation:, error_message: 'Matched conditions of winter') }
      let(:group) { :validating_conditions }
      let(:paradox_conditions) do
        [
          described_class.create(qualifiable:, group:, organisation:, compare_attribute: :begins_at,
                                 compare_operator: :<=, compare_value: '*-03-01'),
          described_class.create(qualifiable:, group:, organisation:, compare_attribute: :begins_at,
                                 compare_operator: :>=, compare_value: '*-09-31')
        ]
      end

      it 'lists both conditions as paradox' do
        expect(paradox_conditions.first.paradox_conditions).to contain_exactly(*paradox_conditions)
        expect(paradox_conditions.last.paradox_conditions).to contain_exactly(*paradox_conditions)
      end
    end

    context 'without paradox conditions in same context' do
      let(:qualifiable) { BookingValidation.create(organisation:, error_message: 'Matched conditions of winter') }
      let(:group) { :validating_conditions }
      let(:paradox_conditions) do
        [
          described_class.create(qualifiable:, group:, organisation:, compare_attribute: :begins_at,
                                 compare_operator: :>=, compare_value: '*-03-01'),
          described_class.create(qualifiable:, group:, organisation:, compare_attribute: :begins_at,
                                 compare_operator: :<=, compare_value: '*-09-31')
        ]
      end

      it 'lists no conditions as paradox' do
        expect(paradox_conditions.first.paradox_conditions).to be_blank
        expect(paradox_conditions.last.paradox_conditions).to be_blank
      end
    end
  end
end
