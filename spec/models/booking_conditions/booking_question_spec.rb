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

RSpec.describe BookingConditions::BookingQuestion, type: :model do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:booking) { create(:booking, organisation:) }
    let(:compare_value) { nil }
    let(:compare_operator) { :'=' }
    let(:compare_attribute) { question.id }
    let(:organisation) { create(:organisation) }
    let(:booking_condition) do
      described_class.create(compare_value:, organisation:,
                             compare_operator:, compare_attribute:)
    end

    context 'with a string question' do
      let(:question) do
        create(:booking_question, type: BookingQuestions::String.to_s, label: 'Test',
                                  required: false, organisation:)
      end
      let!(:response) do
        booking.booking_question_responses.create(booking_question: question, value: 'Hello')
      end

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_operator) { :'=' }
        let(:compare_value) { 'Wrong' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :'=' }
        let(:compare_value) { 'Hello' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end

    context 'with a integer question' do
      let(:question) do
        create(:booking_question, type: BookingQuestions::Integer.to_s, label: 'Test',
                                  required: false, organisation:)
      end
      let!(:response) do
        booking.booking_question_responses.create(booking_question: question, value: 13)
      end

      it { is_expected.to be_falsy }

      context 'with non-matching condition' do
        let(:compare_operator) { :> }
        let(:compare_value) { '20' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_falsy }
      end

      context 'with matching condition' do
        let(:compare_operator) { :> }
        let(:compare_value) { '10' }

        it { expect(booking_condition).to be_valid }
        it { is_expected.to be_truthy }
      end
    end
  end
end
