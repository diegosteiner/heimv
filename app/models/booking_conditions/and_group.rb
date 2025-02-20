# frozen_string_literal: true

module BookingConditions
  class AndGroup < BookingCondition
    include StoreModel::NestedAttributes
    BookingCondition.register_subtype self

    attribute :conditions, BookingCondition.one_of.to_array_type, default: -> { [] }

    accepts_nested_attributes_for :conditions, allow_destroy: true

    validates :conditions, store_model: true

    def evaluate!(booking)
      conditions.all { it.evaluate!(booking) }
    end
  end
end
