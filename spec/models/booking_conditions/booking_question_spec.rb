# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingConditions::BookingQuestion do
  describe '#evaluate' do
    subject { booking_condition.evaluate!(booking) }

    let(:booking) { create(:booking, organisation:) }
    let(:compare_value) { nil }
    let(:compare_operator) { :'=' }
    let(:compare_attribute) { question.id }
    let(:organisation) { create(:organisation) }
    let(:booking_condition) do
      described_class.new(compare_value:, organisation:,
                          compare_operator:, compare_attribute:)
    end

    before do
      qualifiable = instance_double('Qualifiable') # rubocop:disable RSpec/VerifiedDoubleReference
      allow(qualifiable).to receive(:organisation).and_return(organisation)
      allow(booking_condition).to receive(:qualifiable).and_return(qualifiable)
    end

    context 'with a string question' do
      let(:question) do
        create(:booking_question, type: BookingQuestions::String.to_s, label: 'Test', organisation:)
      end

      before { booking.booking_question_responses.create(booking_question: question, value: 'Hello') }

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
                                  organisation:)
      end

      before { booking.booking_question_responses.create(booking_question: question, value: 13) }

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
