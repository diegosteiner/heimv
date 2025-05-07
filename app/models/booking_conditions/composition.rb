# frozen_string_literal: true

module BookingConditions
  class Composition < BookingCondition
    include StoreModel::NestedAttributes

    attribute :conditions, BookingCondition.one_of.to_array_type, default: -> { [] }

    accepts_nested_attributes_for :conditions, allow_destroy: true

    validates :conditions, store_model: true

    def evaluate!(booking)
      conditions.all { it.evaluate!(booking) }
    end

    def initialize_copy(origin)
      super
      self.conditions = origin.conditions.map(&:dup)
    end
  end
end
