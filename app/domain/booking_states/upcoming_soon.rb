# frozen_string_literal: true

module BookingStates
  class UpcomingSoon < BookingState
    RichTextTemplate.require_template(:upcoming_soon_notification, %i[booking])

    def checklist
      []
    end

    def self.to_sym
      :upcoming_soon
    end

    def self.successors
      %i[cancelation_pending active]
    end

    after_transition do |booking|
      booking.notifications.new(from_template: :upcoming_soon_notification, addressed_to: :tenant)&.deliver
    end

    infer_transition(to: :active) do |booking|
      booking.occupancy.today? || booking.occupancy.past?
    end

    def relevant_time
      booking.occupancy.begins_at
    end
  end
end
