# frozen_string_literal: true

module Public
  class HomeSerializer < OccupiableSerializer
    association :occupiables, blueprint: Public::OccupiableSerializer do |home|
      home.self_and_occupiables.occupiable.kept
    end

    view :bookable do
      association :occupiables, blueprint: Public::OccupiableSerializer do |home|
        home.self_and_occupiables.bookable.occupiable.kept
      end
    end
  end
end
