module BookingStrategy
  class Default
    module BookingActions
      extend BookingStrategy::Base::BookingActions

      ACTIONS = [Accept, EmailContractAndDeposit, EmailInvoice, ExtendDeadline, Cancel].map do |action_klass|
        [action_klass.action_name, action_klass]
      end.to_h.with_indifferent_access.freeze
    end
  end
end
