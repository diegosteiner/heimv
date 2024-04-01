# frozen_string_literal: true

module BookingActions
  module Public
    def self.all
      @all ||= [
        CommitRequest,
        CommitBookingAgentRequest,
        PostponeDeadline,
        Cancel
      ].index_by(&:to_sym)
    end
  end
end
