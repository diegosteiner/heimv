# frozen_string_literal: true

module BookingStates
  class Initial < Base
    def self.to_sym
      :initial
    end
  end
end
