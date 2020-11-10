# frozen_string_literal: true

module Public
  class OccupancyCalendarSerializer < ApplicationSerializer
    association :home, blueprint: Public::HomeSerializer
    association :occupancies, blueprint: Public::OccupancySerializer

    fields :window_from, :window_to

    # field :links do
    # end
  end
end
