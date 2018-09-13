class UsageBuilder
  attr_reader :booking

  def initialize(booking)
    @booking = booking
  end

  def build(tarifs = @booking.home.tarifs, usages = @booking.usages)
    used_tarif_ids = usages.map { |usage| [usage.tarif_id, usage.tarif&.booking_copy_template_id] }.flatten
    tarifs.where.not(id: used_tarif_ids).map do |tarif|
      # booking.usages.build(tarif: tarif, apply: nil)
      Usage.new(tarif: tarif, apply: nil, booking: booking)
    end
  end

  def select(usages = @booking.usages, tarif_selectors = @booking.home.tarif_selectors)
    # TODO: Move into tarif_tarif_selector?
    usages.map do |usage|
      votes = tarif_selectors.map do |tarif_selector|
        tarif_selector.vote_for(usage)
      end.flatten

      usage.apply ||= votes.any? && votes.all?
      usage
    end
  end

  def build_and_select
    select(build)
  end
end
