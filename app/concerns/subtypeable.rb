# frozen_string_literal: true

module Subtypeable
  extend ActiveSupport::Concern

  # included do
  #   scope :disabled, -> { where(disabled: true) }

  # end

  class_methods do
    def register_subtype(klass, name: klass.to_s.to_sym, &block)
      subtypes[name] = klass
      instance_eval(&block) if block.present?
      subtypes
    end

    def subtypes
      @subtypes ||= {}
    end
  end
end
