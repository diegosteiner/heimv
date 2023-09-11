# frozen_string_literal: true

module BookingStates
  class Upcoming < Base
    RichTextTemplate.require_template(:upcoming_notification, template_context: %i[booking], required_by: self)
    RichTextTemplate.require_template(:operator_upcoming_notification, template_context: %i[booking], required_by: self)

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
      booking.occupied! if occupied_occupancy_state?(booking)
    end

    after_transition do |booking|
      booking.deadline&.clear
      booking.notifications.new(template: :upcoming_notification, to: booking.tenant).deliver
    end

    after_transition do |booking|
      booking.responsibilities.slice(:home_handover, :home_return).values.uniq.each do |operator|
        next if operator.email.blank?

        booking.notifications.new(template: :operator_upcoming_notification, to: operator)&.deliver
      end
    end

    infer_transition(to: :upcoming_soon) do |booking|
      booking.organisation.settings.upcoming_soon_window.from_now > booking.begins_at
    end

    def relevant_time
      booking.begins_at
    end
  end
end
