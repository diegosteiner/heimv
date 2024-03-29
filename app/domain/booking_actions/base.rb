# frozen_string_literal: true

module BookingActions
  class Base
    Result = Struct.new(:ok, :redirect_proc, keyword_init: true) do
      def self.ok(**)
        new(ok: true, **)
      end
    end
    NotAllowed = Class.new(StandardError)

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

    def call
      raise NotAllowed unless allowed?

      call!
    end

    def self.call(context)
      new(context).call
    end

    def self.allowed?(context)
      new(context).allowed?
    end

    def self.action_name
      name.demodulize.underscore
    end

    def to_s
      self.class.action_name
    end

    def redirect_to; end

    def button_options
      {
        variant: 'primary'
      }
    end
  end
end
