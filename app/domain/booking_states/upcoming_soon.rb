# frozen_string_literal: true

module BookingStates
  class UpcomingSoon < Base
    RichTextTemplate.require_template(:upcoming_soon_notification,
                                      context: %i[booking], required_by: self, optional: true)
    RichTextTemplate.require_template(:operator_upcoming_soon_notification,
                                      context: %i[booking], required_by: self, optional: true)

    def checklist
      []
    end

    def responsibilities
      %i[home_handover home_return]
    end

    def self.to_sym
      :upcoming_soon
    end

    after_transition do |booking|
      operators = [booking.operator_for(:home_handover), booking.operator_for(:home_return)].compact.map(&:email).uniq
      operators.each do |operator_email|
        booking.notifications.new(from_template: :operator_upcoming_soon_notification, to: operator_email)&.deliver
      end
    end

    after_transition do |booking|
      notification = booking.notifications.new(from_template: :upcoming_soon_notification, to: booking.tenant)
      next unless notification.valid?

      notification.attach(DesignatedDocument.in_context(booking).with_locale(booking.locale).house_rules.blobs)
      notification.save! && notification.deliver
    end

    infer_transition(to: :active) do |booking|
      booking.occupancy.today? || booking.occupancy.past?
    end

    def relevant_time
      booking.occupancy.begins_at
    end
  end
end
