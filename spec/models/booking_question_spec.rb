# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_questions
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb
#  discarded_at     :datetime
#  key              :string
#  label_i18n       :jsonb
#  options          :jsonb
#  ordinal          :integer
#  required         :boolean          default(FALSE)
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_booking_questions_on_discarded_at     (discarded_at)
#  index_booking_questions_on_organisation_id  (organisation_id)
#  index_booking_questions_on_type             (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
require 'rails_helper'

RSpec.describe BookingQuestion, type: :model do
  let(:organisation) { create(:organisation) }
  let(:questions) do
    BookingQuestion.subtypes.values.map do |type|
      create(:booking_question, type: type, organisation: organisation)
    end
  end

  describe Manage::BookingQuestionParams do
    describe '::sanitize_booking_params' do
      let(:booking) { create(:booking, organisation: organisation) }
      let(:params) { (questions.to_h { |q| [q.id.to_s, 'test'] }).merge({ 'nonsense' => [1, 2] }) }
      subject(:sanitized) { described_class.sanitize_booking_params(booking, params) }

      it 'applies only valid data' do
        expect(sanitized.keys).to eq(questions.map(&:id))
        expect(sanitized.values).to all eq('test')
      end
    end
  end
end
