# frozen_string_literal: true

module Polymorphable
  extend ActiveSupport::Concern

  # included do
  #   scope :disabled, -> { where(disabled: true) }

  # end

  class_methods do
    def register_polymorphable_type(name, klass)
      polymorphable_types[name] = klass
    end

    def polymorphable_types
      @polymorphable_types ||= {}
    end
  end
end
