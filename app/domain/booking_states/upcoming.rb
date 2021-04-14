# frozen_string_literal: true

module BookingStates
  class Upcoming < BookingState
    RichTextTemplate.require_template(:upcoming_notification, %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :upcoming
    end

    def self.successors
      %i[cancelation_pending upcoming_soon]
    end

    after_transition do |booking|
      booking.occupancy.occupied!
      booking.deadline&.clear
      booking.notifications.new(from_template: :upcoming_notification, addressed_to: :tenant).deliver
    end

    infer_transition(to: :upcoming_soon) do |booking|
      14.days.from_now > booking.occupancy.begins_at
    end

    def relevant_time
      booking.occupancy.begins_at
    end
  end
end
