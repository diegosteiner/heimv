module Public
  class OccupancyCalendarSerializer < ApplicationSerializer
    belongs_to :home
    has_many :occupancies, serializer: Public::OccupancySerializer

    attributes :window_from, :window_to

    attribute :links do
    end
  end
end
