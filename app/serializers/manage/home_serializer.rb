module Manage
  class HomeSerializer < Public::HomeSerializer
    # has_many :bookings

    attributes :name, :ref
  end
end
