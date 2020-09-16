# frozen_string_literal: true

module Manage
  class ContractSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancy,booking.tenant,booking.home'

    association :booking, blueprint: Manage::BookingSerializer

    fields :sent_at, :signed_at
  end
end
