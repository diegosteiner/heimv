class TarifService
  def attach_tarifs_to_booking(booking, tarifs = booking.home.tarifs)
    booking.tarifs = tarifs.map do |base_tarif|
      tarif = base_tarif.dup
      tarif.home = nil
      tarif.template = base_tarif
      tarif.usages = [tarif.usages.build(booking: booking)]
      tarif
    end
  end
end
