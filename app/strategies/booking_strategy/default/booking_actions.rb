module BookingStrategy
  class Default
    module BookingActions
      ACTIONS = [Accept, EmailContractAndDeposit, EmailInvoice, ExtendDeadline, Cancel].map do |action_klass|
        [action_klass.action_name, action_klass]
      end.to_h.with_indifferent_access.freeze

      def self.available_actions(booking, publicly_available_only: false)
        ACTIONS.values.select do |action_klass|
# (publicly_available_only && !action_klass.publicly_available?)
          action_klass.available_on?(booking)
        end.map(&:new)
      end

      def self.[](action_name, publicly_available_only: false)
        action_klass = ACTIONS[action_name]
        return if !action_klass || (publicly_available_only && !action_klass.publicly_available?)

        action_klass.new
      end
    end
  end
end
