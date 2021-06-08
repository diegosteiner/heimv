# frozen_string_literal: true

module Public
  class BookingPurposeSerializer < ApplicationSerializer
    fields :key, :title_i18n, :title
  end
end
