module Public
  class ContractSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancy,booking.tenant,booking.home'.freeze
    belongs_to :booking
  end
end
