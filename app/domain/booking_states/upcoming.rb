# frozen_string_literal: true

module BookingStates
  class Upcoming < Base
    RichTextTemplate.require_template(:upcoming_notification, %i[booking], self)

    def checklist
      []
    end

    def self.to_sym
      :upcoming
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
