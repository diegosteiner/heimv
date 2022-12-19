# frozen_string_literal: true

module BookingStates
  class CancelationPending < Base
    RichTextTemplate.require_template(:operator_cancelation_pending_notification,
                                      context: %i[booking], required_by: self, optional: true)
    def checklist
      []
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :cancelation_pending
    end

    def self.successors
      %i[cancelled overdue]
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.update!(editable: false)
    end

    after_transition do |booking|
      OperatorResponsibility.for_booking(booking, :home_handover, :home_return).each do |operator|
        next if operator.email.blank?

        booking.notifications.new(template: :operator_cancellation_pending_notification, to: operator)&.deliver
      end
    end

    infer_transition(to: :cancelled) do |booking|
      !booking.invoices.kept.open.exists?
    end

    def relevant_time; end
  end
end
