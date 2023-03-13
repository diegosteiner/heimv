# frozen_string_literal: true

module Public
  class OccupiableSerializer < ApplicationSerializer
    fields :id, :name, :description, :active, :occupiable, :home_id
  end
end
