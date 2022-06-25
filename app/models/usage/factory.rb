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

    def preselect(usages = build)
      usages.select(&:preselect)
    end
  end
end
