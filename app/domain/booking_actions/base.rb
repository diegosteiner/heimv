# frozen_string_literal: true

module BookingActions
  class Base
    Result = Struct.new(:success, :redirect_proc, :error, keyword_init: true) do
      def self.success(**)
        new(success: true, **)
      end

      def self.failure(**)
        new(success: false, **)
      end
    end

    include Translatable
    extend Translatable
    attr_reader :context

    def initialize(context)
      @context = context
    end

    def self.templates
      @templates ||= []
    end

    def label
      # i18n-tasks-ignore
      translate(:label)
    end

    def invoke(*)
      # i18n-tasks-ignore
      return Result.failure error: translate(:not_allowed) unless allowed?

      invoke!(*)
    end

    def self.to_sym
      name.demodulize.underscore.to_sym
    end

    def to_sym
      self.class.to_sym
    end

    def variant
      :primary
    end

    def confirm
      nil
    end
  end
end
