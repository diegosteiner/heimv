# frozen_string_literal: true

module BookingActions
  module Manage
    class CommitRequest < BookingActions::Base
      def invoke!
        Result.new success: booking.update(committed_request: true)
      end

      def allowed?
        booking.valid? && !booking.committed_request
      end

      def confirm
        I18n.t(:confirm)
      end
    end
  end
end
