# frozen_string_literal: true

module BookingStates
  class UpcomingSoon < Base
    RichTextTemplate.require_template(:upcoming_soon_notification,
                                      template_context: %i[booking], required_by: self, optional: true)
    RichTextTemplate.require_template(:operator_upcoming_soon_notification,
                                      template_context: %i[booking], required_by: self, optional: true)

    def checklist
      []
    end

    def invoice_type
      Invoices::Deposit
    end

    def responsibilities
      %i[home_handover home_return]
    end

    def self.to_sym
      :upcoming_soon
    end

    after_transition do |booking|
      booking.responsibilities.slice(:home_handover, :home_return).each_value do |operator|
        next if operator.email.blank?

        booking.notifications.new(template: :operator_upcoming_soon_notification, to: operator)&.deliver
      end
    end

    after_transition do |booking|
      notification = booking.notifications.new(template: :upcoming_soon_notification, to: booking.tenant)
      next unless notification.valid?

      notification.attach(DesignatedDocument.for_booking(booking).where(send_with_last_infos: true))
      notification.save! && notification.deliver
    end

    infer_transition(to: :active) do |booking|
      booking.today? || booking.past?
    end

    def relevant_time
      booking.begins_at
    end
  end
end
