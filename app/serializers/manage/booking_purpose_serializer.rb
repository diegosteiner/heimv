# frozen_string_literal: true

module Manage
  class BookingPurposeSerializer < Public::BookingPurposeSerializer
    view :export do
      include_view :default
    end
  end
end
