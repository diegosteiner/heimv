# frozen_string_literal: true

module BookingActions
  class Base
    class NotInvokable < StandardError; end

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
      raise NotInvokable unless invokable?(**)

      invoke!(**)
    rescue Statesman::TransitionConflictError, NotInvokable
      Result.failure error: translate(:not_allowed)
    rescue StandardError => e
      raise e unless Rails.env.production?

      Result.failure error: e.message
    end

    def invokable?(current_user: nil)
      false
    end

    def invokable_with(current_user: nil)
      {} if invokable?(current_user:)
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
