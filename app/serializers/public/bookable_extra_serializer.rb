# frozen_string_literal: true

module Public
  class BookableExtraSerializer < ApplicationSerializer
    fields :id, :title_i18n, :description_i18n
  end
end
