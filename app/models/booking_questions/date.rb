# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_questions
#
#  id                   :bigint           not null, primary key
#  applying_conditions  :jsonb
#  booking_agent_mode   :integer          default("not_visible")
#  description_i18n     :jsonb            not null
#  discarded_at         :datetime
#  key                  :string
#  label_i18n           :jsonb            not null
#  options              :jsonb
#  ordinal              :integer
#  requiring_conditions :jsonb
#  tenant_mode          :integer          default("not_visible"), not null
#  type                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organisation_id      :bigint           not null
#
module BookingQuestions
  class Date < BookingQuestion
    BookingQuestion.register_subtype self

    def cast(value)
      ActiveModel::Type::Date.new.cast(value)
    end
  end
end
