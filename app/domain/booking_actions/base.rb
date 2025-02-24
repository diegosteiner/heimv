# frozen_string_literal: true

module BookingActions
  class Base
    class NotAllowed < StandardError; end
    Result = Struct.new(:success, :redirect_proc, :error, keyword_init: true) do
      def self.success(**)
        new(success: true, **)
      end

      def self.failure(**)
        new(success: false, **)
      end
    end

    include Translatable
    include TemplateRenderable
    extend Translatable
    attr_reader :booking

    def initialize(booking)
      @booking = booking
    end

    def self.templates
      @templates ||= []
    end

    delegate :label, to: :class

    def self.label
      # i18n-tasks-ignore
      translate(:label, default: try(:model_name) || to_s)
    end

    def invoke(...)
      raise NotAllowed unless allowed?

      invoke!(...)
    rescue Statesman::TransitionConflictError, NotAllowed
      # i18n-tasks-ignore
      Result.failure error: translate(:not_allowed)
    rescue StandardError => e
      Result.failure error: e.message
    end

    def self.to_sym
      name.demodulize.underscore.to_sym
    end

    delegate :to_sym, to: :class

    def variant
      :primary
    end

    def confirm
      nil
    end

    def prepare?
      false
    end

    def self.params_schema; end
  end
end
