# frozen_string_literal: true

module BookingActions
  class Base
    include Translatable
    include TemplateRenderable
    extend Translatable
    extend RichTextTemplate::Definition
    attr_reader :booking, :key

    delegate :label, to: :class

    Result = Struct.new(:success, :redirect_proc, :error, keyword_init: true) do
      def self.success(**)
        new(success: true, **)
      end

      def self.failure(**)
        new(success: false, **)
      end
    end

    def initialize(booking, key)
      @booking = booking
      @key = key&.to_sym
    end

    def invoke(**)
      raise ArgumentError unless invokable?(**)

      invoke!(**)
    rescue Statesman::TransitionConflictError, ArgumentError
      Result.failure error: translate(:not_allowed)
    rescue StandardError => e
      Result.failure error: e.message
    end

    def invokable?
      false
    end

    def invokable_with
      {} if invokable?
    end

    def prepare_with; end
    def invoke_schema; end

    class << self
      def label
        # i18n-tasks-ignore
        translate(:label, default: try(:model_name) || to_s)
      end
    end
  end
end
