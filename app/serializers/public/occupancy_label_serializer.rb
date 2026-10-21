# frozen_string_literal: true

module Public
  class OccupancyLabelSerializer < ApplicationSerializer
    identifier :id
    fields :color, :title_i18n, :title, :description_i18n
  end
end
