# frozen_string_literal: true

module Implementable
  def implementations
    @implementations ||= {}
  end

  def [](klass_or_instance)
    klass = klass_or_instance.is_a?(Class) ? klass_or_instance : klass_or_instance.class
    implementations[klass] || implementations.find { klass.ancestors.include?(_1) }
  end

  def implement_for(klass, &)
    implementations[klass] = Class.new(self, &)
  end
end
