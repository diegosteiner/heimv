# frozen_string_literal: true

module BookingStates
  class Active < Base
    def checklist
      []
    end

    def self.to_sym
      :active
    end

    def invoice_type
      Invoices::Invoice
    end

    after_transition do |booking|
      booking.occupied!
    end

    infer_transition(to: :past, &:past?)

    def relevant_time
      booking.ends_at
    end
  end
end
