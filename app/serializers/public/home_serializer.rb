# frozen_string_literal: true

module Public
  class HomeSerializer < OccupiableSerializer
    field :occupiables, association: true, blueprint: Public::OccupiableSerializer do |home|
      home.occupiables.active.occupiable
    end
  end
end
