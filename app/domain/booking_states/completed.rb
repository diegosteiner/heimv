# frozen_string_literal: true

module BookingStates
  class Completed < Base
    use_mail_template(:completed_notification, context: %i[booking], optional: true)
    def checklist
      []
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :completed
    end

    guard_transition do |booking|
      !booking.invoices.kept.unsettled.exists?
    end

    after_transition do |booking|
      booking.deadline&.clear!
      booking.conclude
      MailTemplate.use(:completed_notification, booking, to: :tenant, &:autodeliver!)
    end

    def relevant_time; end
  end
end
