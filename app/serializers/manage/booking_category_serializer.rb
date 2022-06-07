# frozen_string_literal: true

module Manage
  class BookingCategorySerializer < Public::BookingCategorySerializer
    view :export do
      fields :key, :title_i18n, :ordinal
    end
  end
end
