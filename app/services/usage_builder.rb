class UsageBuilder
  def from_tarifs(booking, tarifs = booking.home.tarifs, usages = booking.usages)
    used_tarif_ids = usages.map { |usage| [usage.tarif_id, usage.tarif&.booking_copy_template_id] }.flatten
    tarifs.where.not(id: used_tarif_ids).map do |tarif|
      booking.usages.build(tarif: tarif, apply: false)
    end
  end

  def apply_calculators(booking, usage_calculators = booking.home.usage_calculators)
    x = usage_calculators.map do |usage_calculator|
      usage_calculator.calculate(booking, booking.usages)
    end
    Rails.logger.debug x.inspect
    x
  end

  def for_booking(booking)
    from_tarifs(booking)
    apply_calculators(booking)
    booking.usages
  end
end
