# frozen_string_literal: true

module BookingActions
  module Public
    def self.all
      @all ||= [
        CommitRequest,
        CommitBookingAgentRequest,
        PostponeDeadline,
        Cancel
      ].index_by(&:action_name)
    end
  end
end
