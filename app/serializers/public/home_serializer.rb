module Public
  class HomeSerializer < ApplicationSerializer
    # has_many :bookings

    attributes :name, :ref, :janitor, :place
  end
end
