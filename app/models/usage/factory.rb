# frozen_string_literal: true

class Usage
  class Factory
    attr_reader :booking

    def initialize(booking)
      @booking = booking
    end

    def build(tarifs: booking.organisation.tarifs.where(home_id: [booking.home, nil]).ordered, usages: booking.usages)
      tarifs.where.not(id: usages.map(&:tarif_id)).map do |tarif|
        Usage.new(tarif: tarif, apply: nil, booking: booking)
      end
    end

    def preselect
      usages.select(&:preselect)
    end
  end
end
