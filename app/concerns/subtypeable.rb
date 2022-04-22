# frozen_string_literal: true

module Subtypeable
  extend ActiveSupport::Concern

  # included do
  #   scope :disabled, -> { where(disabled: true) }

  # end

  class_methods do
    def register_subtype(klass, name: klass.to_s.to_sym)
      subtypes[name] = klass
    end

    def subtypes
      @subtypes ||= {}
    end
  end
end
