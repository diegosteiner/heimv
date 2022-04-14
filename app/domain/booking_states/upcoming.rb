# frozen_string_literal: true

module BookingStates
  class Upcoming < Base
    RichTextTemplate.require_template(:upcoming_notification, context: %i[booking], required_by: self)

    def checklist
      []
    end

    def self.to_sym
      :upcoming
    end

    def self.hidden
      true
    end

    def responsibilities
      %i[home_handover home_return]
    end

    after_transition do |booking|
      booking.occupancy.occupied!
      booking.deadline&.clear
      OperatorResponsibilityAssignmentService.new(booking).assign(:home_handover, :home_return)
      booking.notifications.new(template: :upcoming_notification, to: booking.tenant).deliver
    end

    infer_transition(to: :upcoming_soon) do |booking|
      booking.home.settings.upcoming_soon_window.from_now > booking.occupancy.begins_at
    end

    def relevant_time
      booking.occupancy.begins_at
    end
  end
end
