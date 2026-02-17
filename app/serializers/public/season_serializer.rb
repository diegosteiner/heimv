# frozen_string_literal: true

module Public
  class SeasonSerializer < ApplicationSerializer
    identifier :id

    fields :status, :label_i18n
  end
end
