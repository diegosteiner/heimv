class BookingStrategy
  class BookingActions
    def self.allowed_actions(booking)
      actions.values.map { |action_klass| action_klass.new(booking) }.select(&:allowed?)
    end

    def self.actions
      @actions || {}
    end

    def self.register(action_klass)
      @actions = actions.merge(action_klass.action_name.to_sym => action_klass)
    end

    def self.[](action_name)
      actions[action_name.to_sym]
    end
  end
end
