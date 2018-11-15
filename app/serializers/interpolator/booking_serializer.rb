class Interpolator
  class BookingSerializer < Base
    def unflattened_serializable_hash
      {
        booking: Public::BookingSerializer.new(@subject)
                  .serializable_hash(include: Public::BookingSerializer::DEFAULT_INCLUDES),
        edit_manage_booking_url: edit_manage_booking_url(@subject.to_param),
        edit_public_booking_url: edit_public_booking_url(@subject.to_param)
      }
    end
  end
end
