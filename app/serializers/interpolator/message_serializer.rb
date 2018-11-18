class Interpolator
  class MessageSerializer < Base
    def unflattened_serializable_hash
      {
        subject: @subject.subject,
        booking: Public::BookingSerializer.new(@subject.booking)
                                          .serializable_hash(include: Public::BookingSerializer::DEFAULT_INCLUDES),
        edit_manage_booking_url: edit_manage_booking_url(@subject.booking.to_param),
        edit_public_booking_url: edit_public_booking_url(@subject.booking.to_param)
      }
    end
  end
end
