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
end
