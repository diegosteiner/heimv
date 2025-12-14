# frozen_string_literal: true

module Public
  class BookingQuestionSerializer < ApplicationSerializer
    identifier :id
    fields :key, :label_i18n, :ordinal, :description_i18n, :type, :label, :description
  end
end
