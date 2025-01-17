# frozen_string_literal: true

module BookingStates
  def self.[](key)
    all[key&.to_sym]
  end

  def self.all
    @all ||= [
      UnconfirmedRequest, OpenRequest, ProvisionalRequest, DefinitiveRequest, BookingAgentRequest, AwaitingTenant,
      AwaitingContract, Overdue, UpcomingSoon, Upcoming, Active, Past, PaymentDue, CancelationPending, Completed,
      CancelledRequest, DeclinedRequest, Cancelled, OverdueRequest, PaymentOverdue, Initial
    ].index_by(&:to_sym)
  end
end
