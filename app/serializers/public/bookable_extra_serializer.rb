# frozen_string_literal: true

module Public
  class BookableExtraSerializer < ApplicationSerializer
    fields :key, :title_i18n, :description_i18n
  end
end
