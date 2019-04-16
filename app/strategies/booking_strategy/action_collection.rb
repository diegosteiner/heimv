class BookingStrategy
  class ActionCollection
    def initialize(actions)
      actions.each { |action_klass| register(action_klass) }
    end

    def allowed_actions(booking)
      actions.values.map { |action_klass| action_klass.new(booking) }.select(&:allowed?)
    end

    def actions
      @actions || {}
    end

    def register(action_klass)
      @actions = actions.merge(action_klass.action_name.to_sym => action_klass)
    end

    def [](action_name)
      actions[action_name.to_sym]
    end
  end
end
