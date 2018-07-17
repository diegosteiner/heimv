class TarifBuilder
  def for_booking(booking, tarifs = booking.home.tarifs)
    booking.tarifs = tarifs.map do |template_tarif|
      next if template_tarif.transient
      tarif = template_tarif.dup
      tarif.template = template_tarif
    end.compact
  end
end
