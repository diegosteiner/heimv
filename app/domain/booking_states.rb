# frozen_string_literal: true

module BookingStates
  def self.all
    @all ||= [
      UnconfirmedRequest, OpenRequest, ProvisionalRequest, DefinitiveRequest, BookingAgentRequest, AwaitingTenant,
      AwaitingContract, Overdue, UpcomingSoon, Upcoming, Active, Past, PaymentDue, CancelationPending, Completed,
      CancelledRequest, DeclinedRequest, Cancelled, OverdueRequest, PaymentOverdue, Initial
    ].index_by(&:to_sym)
  end

  def self.displayed_by_default
    all.values.filter_map { |state| state.to_sym unless state.hidden }
  end

  def self.occupied_occupancy_able
    @occupied_occupancy_able ||= [DefinitiveRequest, AwaitingTenant, AwaitingContract,
                                  Upcoming, UpcomingSoon].index_by(&:to_sym)
  end
end
