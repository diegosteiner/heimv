# frozen_string_literal: true

module Public
  class OccupancyCalendarSerializer < ApplicationSerializer
    belongs_to :home, serializer: Public::HomeSerializer
    has_many :occupancies, serializer: Public::OccupancySerializer

    attributes :window_from, :window_to

    attribute :links do
    end
  end
end
