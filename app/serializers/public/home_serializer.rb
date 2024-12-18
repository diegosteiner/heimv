# frozen_string_literal: true

module Public
  class HomeSerializer < OccupiableSerializer
    # fields :accounting_account_nr
    association :occupiables, blueprint: Public::OccupiableSerializer do |home|
      home.occupiables.kept
    end
  end
end
