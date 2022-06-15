# frozen_string_literal: true

module Public
  class BookingCategorySerializer < ApplicationSerializer
    fields :key, :title_i18n, :title
  end
end