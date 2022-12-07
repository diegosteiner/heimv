# frozen_string_literal: true

class Usage
  class Factory
    attr_reader :booking

    def initialize(booking)
      @booking = booking
    end

    def build(tarifs: booking.organisation.tarifs.include_conditions.ordered.kept, preselect: false)
      tarifs.where.not(id: booking.usages.map(&:tarif_id)).map do |tarif|
        Usage.new(tarif: tarif, apply: nil, booking: booking).tap do |usage|
          next unless preselect

          usage.apply ||= usage.selected_by_condition?
          usage.used_units ||= usage.presumed_units
        end
      end.filter(&:enabled_by_condition?)
    end
  end
end
