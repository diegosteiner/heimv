class Interpolator
  class InvoiceSerializer < Base
    def unflattened_serializable_hash
      Public::InvoiceSerializer.new(@subject)
                               .serializable_hash(include: Public::InvoiceSerializer::DEFAULT_INCLUDES)
      # .merge({
      #   edit_manage_booking_url: edit_manage_booking_url(subject.to_param),
      #   edit_public_booking_url: edit_public_booking_url(subject.to_param)
      # })
    end
  end
end
