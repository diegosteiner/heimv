# frozen_string_literal: true

module BookingActions
  module Public
    class PostponeDeadline < BookingActions::Base
      def call!
        return booking.deadline.postpone if allowed?

        booking.deadline.errors.add(:base, :not_postponable)
      end

      def allowed?
        booking.deadline&.postponable? && booking.deadline.postponable_until < booking.occupancy.begins_at
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
