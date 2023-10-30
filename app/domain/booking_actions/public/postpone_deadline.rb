# frozen_string_literal: true

module BookingActions
  module Public
    class PostponeDeadline < BookingActions::Base
      def call!
        Result.new ok: booking.deadline.postpone
      end

      def allowed?
        booking.deadline&.postponable? && booking.deadline.postponable_until < booking.begins_at
      end

      def booking
        context.fetch(:booking)
      end
    end
  end
end
