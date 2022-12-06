# frozen_string_literal: true

class Usage
  class Factory
    attr_reader :booking

    def initialize(booking)
      @booking = booking
    end

    def build(tarifs: booking.organisation.tarifs.include_conditions, usages: booking.usages, preselect: false)
      tarifs.where.not(id: usages.map(&:tarif_id)).filter_map do |tarif|
        usage = Usage.new(tarif: tarif, apply: nil, booking: booking)
        next unless usage.enabled_by_condition?

        usage.preselect if preselect
        usage
      end
    end
  end
end
