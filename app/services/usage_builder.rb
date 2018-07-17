class UsageBuilder
  def for_booking(booking, tarifs = Tarif.applicable_to(booking), usages = booking.usages)
    usages + tarifs.where.not(id: usages.map(&:tarif_id)).map do |tarif|
      # TODO: put calculation logic here?
      Usage.new(booking: booking, tarif: tarif)
    end
  end
end
