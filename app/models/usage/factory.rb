# frozen_string_literal: true

class Usage
  class Factory
    attr_reader :booking

    def initialize(booking)
      @booking = booking
    end

    def build(tarifs = @booking.home.tarifs.ordered, usages = @booking.usages)
      used_tarif_ids = usages.map { |usage| [usage.tarif_id, usage.tarif&.booking_copy_template_id] }.flatten
      tarifs.where.not(id: used_tarif_ids).map do |tarif|
        Usage.new(tarif: tarif, apply: nil, booking: booking)
      end
    end

    def prefill(usages); end

    def select(usages = @booking.usages)
      prefiller = TarifPrefiller.new
      usages.each do |usage|
        usage.apply ||= usage.adopted_by_vote?
        usage.used_units ||= prefiller.alleged_units(usage)
      end
    end

    def build_and_select
      select(build)
    end
  end
end
