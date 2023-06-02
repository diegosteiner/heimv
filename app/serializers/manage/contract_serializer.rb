# frozen_string_literal: true

module Manage
  class ContractSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancies,booking.tenant,booking.occupancies.occupiable,booking.home'

    association :booking, blueprint: Manage::BookingSerializer

    fields :sent_at, :signed_at, :locale
  end
end
