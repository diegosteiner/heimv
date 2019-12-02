module Manage
  class DeadlineSerializer < ApplicationSerializer
    belongs_to :booking, serializer: Manage::BookingSerializer

    attributes :at, :postponable_for
  end
end
