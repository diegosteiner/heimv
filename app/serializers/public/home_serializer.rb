# frozen_string_literal: true

module Public
  class HomeSerializer < OccupiableSerializer
    association :occupiables, blueprint: Public::OccupiableSerializer do |home|
      home.occupiables.kept
    end
  end
end
