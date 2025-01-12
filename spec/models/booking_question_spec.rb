# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_questions
#
#  id                 :bigint           not null, primary key
#  booking_agent_mode :integer
#  description_i18n   :jsonb            not null
#  discarded_at       :datetime
#  key                :string
#  label_i18n         :jsonb            not null
#  options            :jsonb
#  ordinal            :integer
#  required           :boolean          default(FALSE)
#  tenant_mode        :integer          default("not_visible"), not null
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
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
      create(:booking_question, type:, organisation:)
    end
  end
end
