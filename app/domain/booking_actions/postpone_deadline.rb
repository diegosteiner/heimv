# frozen_string_literal: true

module BookingActions
  class PostponeDeadline < Base
    def invoke!
      Result.new success: booking.deadline.postpone
    end

    def invokable?
      booking.deadline&.postponable? && booking.deadline.postponable_until < booking.begins_at
    end
  end
end
