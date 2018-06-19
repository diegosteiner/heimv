class TarifGenerator
  def from_booking(booking, tarifs = booking.home.tarifs)
    booking.tarifs = tarifs.map do |template_tarif|
      next template_tarif unless template_tarif.transient
      tarif = template_tarif.dup
      tarif.template = template_tarif
    end
  end
end
