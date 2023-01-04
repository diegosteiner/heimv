# frozen_string_literal: true

module BookingStates
  class Upcoming < Base
    RichTextTemplate.require_template(:upcoming_notification, template_context: %i[booking], required_by: self)

    def checklist
      []
    end

    def self.to_sym
      :upcoming
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.hidden
      true
    end

    def responsibilities
      %i[home_handover home_return]
    end

    after_transition do |booking|
      booking.occupied!
      booking.deadline&.clear
      booking.notifications.new(template: :upcoming_notification, to: booking.tenant).deliver
    end

    infer_transition(to: :upcoming_soon) do |booking|
      booking.organisation.settings.upcoming_soon_window.from_now > booking.begins_at
    end

    def relevant_time
      booking.begins_at
    end
  end
end
