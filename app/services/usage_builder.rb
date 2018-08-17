class UsageBuilder
  def from_tarifs(booking, tarifs = booking.home.tarifs, usages = booking.usages)
    used_tarif_ids = usages.map { |usage| [usage.tarif_id, usage.tarif&.booking_copy_template_id] }.flatten
    tarifs.where.not(id: used_tarif_ids).map do |tarif|
      booking.usages.build(tarif: tarif)
    end
  end

  def apply_calculators(booking, usage_calculators = booking.home.usage_calculators)
    usage_calculators.map do |usage_calculator|
      usage_calculator.apply(booking, booking.usages)
    end
  end

  def for_booking(booking)
    from_tarifs(booking)
    apply_calculators(booking)
    booking.usages
  end
end
