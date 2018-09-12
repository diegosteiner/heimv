module Public
  class HomeSerializer < ApplicationSerializer
    # has_many :bookings

    attributes :name, :ref, :house_rules, :janitor
  end
end
