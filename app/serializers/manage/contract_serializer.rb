# frozen_string_literal: true

module Manage
  class ContractSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancy,booking.tenant,booking.home'
    belongs_to :booking, serializer: Manage::BookingSerializer

    attributes :sent_at, :signed_at
  end
end
