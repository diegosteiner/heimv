# frozen_string_literal: true

class ApplicationParams
  delegate_missing_to :permitted

  def initialize(params)
    @params = params || ActionController::Parameters.new
  end

  def permitted(additional_keys = [])
    @permitted ||= sanitized.permit(self.class.permitted_keys + additional_keys)
  end

  def sanitized
    return @params.dup if self.class.sanitizers.blank?

    @sanitized ||= self.class.sanitizers.reduce(@params.dup) do |params_to_sanitize, block|
      next params_to_sanitize unless block.respond_to?(:call)

      block.call(params_to_sanitize)
    end
  end

  def to_h
    @to_h ||= permitted.to_h
  end

  class << self
    attr_reader :sanitizers

    def sanitize(&block)
      @sanitizers ||= []
      @sanitizers << block
    end

    def permitted_keys
      []
    end
  end
end
