# frozen_string_literal: true

module BookingStates
  class CancelationPending < Base
    RichTextTemplate.require_template(:operator_cancelation_pending_notification,
                                      context: %i[booking], required_by: self, optional: true)
    def checklist
      []
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
      operators = [booking.operator_for(:home_handover), booking.operator_for(:home_return)].compact.map(&:email).uniq
      operators.each do |operator_email|
        booking.notifications.new(template: :operator_cancellation_pending_notification,
                                  to: operator_email)&.deliver
      end
    end

    infer_transition(to: :cancelled) do |booking|
      !booking.invoices.kept.unpaid.exists?
    end

    def relevant_time; end
  end
end
