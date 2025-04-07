# frozen_string_literal: true

module BookingActions
  class PostponeDeadline < Base
    def invoke!(current_user: nil)
      Result.new success: booking.deadline.postpone
    end

    def invokable?(current_user: nil)
      booking.deadline&.postponable? && booking.deadline.postponable_until < booking.begins_at
    end
  end
end
