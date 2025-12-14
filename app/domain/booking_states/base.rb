# frozen_string_literal: true

module BookingStates
  class Base
    extend RichTextTemplate::Definition
    extend Translatable
    include Translatable

    attr_reader :booking

    delegate :to_s, to: :to_sym

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

      def templates
        @templates ||= []
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
        from = from&.to_s
        to = Array(to).compact_blank.map(&:to_s)
        callbacks[callback_type] << callback_class.new(from:, to:, callback: block)
      end

      def infer_transition(to: nil, &)
        add_callback(callback_type: :infer, from: to_sym, to:, &)
      end

      def before_transition(to: nil, &)
        add_callback(callback_type: :before, from: to_sym, to:, &)
      end

      def after_transition(from: nil, &)
        add_callback(callback_type: :after, from:, &)
      end

      def after_transition_failure(from: nil, &)
        add_callback(callback_type: :after_transition_failure, from:, &)
      end

      def after_guard_failure(from: nil, &)
        add_callback(callback_type: :after_guard_failure, from:, &)
      end

      def guard_transition(from: nil, &)
        add_callback(callback_type: :guards, callback_class: Statesman::Guard, from:, &)
      end

      def occupied_booking_state?(booking)
        booking&.organisation&.booking_state_settings&.occupied_booking_states&.include?(to_sym.to_s) # rubocop:disable Style/SafeNavigationChainLength
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

    delegate :to_sym, to: :class

    def checklist
      []
    end

    def roles
      []
    end

    def invoice_type; end

    def relevant_time; end

    def editable
      @booking.organisation&.booking_state_settings&.editable_booking_states&.include?(to_sym.to_s)
    end
  end
end
