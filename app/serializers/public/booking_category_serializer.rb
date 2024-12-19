# frozen_string_literal: true

module Public
  class BookingCategorySerializer < ApplicationSerializer
    identifier :id
    fields :key, :title_i18n, :title, :description_i18n, :ordinal
  end
end
