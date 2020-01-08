class BookingStrategy
  class State
    include Translatable
    attr_reader :booking

    ChecklistItem = Struct.new(:key, :checked, :url_hint)

    def initialize(booking)
      @booking = booking
    end

    delegate :valid?, to: :booking

    def checklist
      []
    end

    def self.to_sym; end

    def relevant_time; end
  end
end
