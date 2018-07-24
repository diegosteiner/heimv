class UsageBuilder
  def for_booking(booking, tarifs = booking.home.tarifs, usages = booking.usages)
    applying_tarifs = usages.map { |usage| [usage.tarif_id, usage.tarif.booking_copy_template_id] }.flatten
    tarifs.where.not(id: applying_tarifs).map do |tarif|
      # TODO: put calculation logic here?
      Usage.new(booking: booking, tarif: tarif, apply: false)
    end
  end
end
