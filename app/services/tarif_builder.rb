class TarifBuilder
  def for_booking(booking, tarifs = booking.home.tarifs)
    tarifs.reject.map do |tarif|
      booking_copy_for(tarif, booking) unless tarif.transient?
    end.compact
  end

  def booking_copy_for(tarif, booking)
    return tarif if tarif.booking == booking
    tarif.dup.tap do |booking_copy|
      booking_copy.booking = booking
      booking_copy.booking_copy_template = tarif
    end
  end
end
