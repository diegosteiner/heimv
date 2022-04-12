# frozen_string_literal: true

module Manage
  class BookingPurposeSerializer < Public::BookingPurposeSerializer
    view :export do
      fields :key, :title_i18n, :ordinal
    end
  end
end
