# frozen_string_literal: true

module BookingStates
  class Base
    extend Translatable
    include Translatable
    attr_reader :booking

    delegate :valid?, to: :booking
    delegate :to_s, to: :to_sym

    ChecklistItem = Struct.new(:key, :checked, :url_hint)

    class << self
      def to_sym
        raise NotImplementedError
      end

      delegate :to_s, to: :to_sym

      def hidden
        false
      end

      def successors
        []
      end

      def callbacks
        @callbacks ||= {
          before: [],
          after: [],
          after_transition_failure: [],
          after_guard_failure: [],
          after_commit: [],
          infer: [],
          guards: []
        }
      end

      def add_callback(callback_type: nil, callback_class: Statesman::Callback, from: nil, to: to_s, &block)
        from = from.nil? ? nil : from.to_s
        to = Array(to).map { _1.nil? ? nil : _1.to_s }
        callbacks[callback_type] << callback_class.new(from: from, to: to, callback: block)
      end

      def infer_transition(to: nil, &block)
        add_callback(callback_type: :infer, from: to_sym, to: to, &block)
      end

      def before_transition(from: nil, &block)
        add_callback(callback_type: :before, from: from, &block)
      end

      def after_transition(from: nil, &block)
        add_callback(callback_type: :after, from: from, &block)
      end

      def after_transition_failure(from: nil, &block)
        add_callback(callback_type: :after_transition_failure, from: from, &block)
      end

      def after_guard_failure(from: nil, &block)
        add_callback(callback_type: :after_guard_failure, from: from, &block)
      end

      def guard_transition(from: nil, &block)
        add_callback(callback_type: :guards, callback_class: Statesman::Guard, from: from, &block)
      end
    end

    def initialize(booking)
      @booking = booking
    end

    def ==(other)
      return to_s == other if other.is_a?(String)
      return to_sym == other if other.is_a?(Symbol)

      if other.is_a?(BookingStates::Base)
        return booking == other.booking &&
               booking.booking_flow.current_state == other.booking_flow.current_state
      end

      super
    end

    def to_sym
      self.class.to_sym
    end

    def checklist
      []
    end

    def public_actions
      []
    end

    def manage_actions
      []
    end

    def relevant_time; end
  end
end
