# frozen_string_literal: true

class Usage
  class Factory
    attr_reader :booking

    def initialize(booking)
      @booking = booking
    end

    def build(tarifs: booking.organisation.tarifs.ordered.kept, preselect: false)
      tarifs.where.not(id: booking.usages.map(&:tarif_id)).map do |tarif|
        Usage.new(tarif:, apply: nil, booking:).tap do |usage|
          next unless preselect

          usage.apply ||= usage.selected_by_conditions?
          usage.used_units ||= usage.presumed_units
        end
      end.filter(&:enabled_by_conditions?)
    end
  end
end
