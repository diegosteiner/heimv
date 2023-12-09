# frozen_string_literal: true

module Public
  class OccupiableSerializer < ApplicationSerializer
    identifier :id
    fields :name, :description, :active, :occupiable, :home_id, :name_i18n, :description_i18n
  end
end
