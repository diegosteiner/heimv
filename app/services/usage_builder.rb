class UsageBuilder
  def build(booking, tarifs = booking.home.tarifs, usages = booking.usages)
    used_tarif_ids = usages.map { |usage| [usage.tarif_id, usage.tarif&.booking_copy_template_id] }.flatten
    tarifs.where.not(id: used_tarif_ids).map do |tarif|
      booking.usages.build(tarif: tarif, apply: nil)
    end
  end

  def select(booking, tarif_selectors = booking.home.tarif_selectors)
    tarif_selectors.map do |tarif_selector|
      tarif_selector.apply_all(booking, booking.usages)
    end
  end

  def for_booking(booking)
    build(booking)
    select(booking)
    booking.usages
  end
end
