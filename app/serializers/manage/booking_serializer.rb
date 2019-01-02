module Manage
  class BookingSerializer < Public::BookingSerializer
    attribute :links do
      {
        edit: edit_manage_booking_url(object.to_param)
      }
    end
  end
end
