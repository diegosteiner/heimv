# frozen_string_literal: true

class BookingStateSettings
  include StoreModel::Model
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attribute :default_manage_transition_to_state, :string, default: -> { BookingStates::ProvisionalRequest.to_s }
  attribute :occupied_occupancy_states, array: true, default: lambda {
    BookingFlows::Default.occupied_by_default.map(&:to_s)
  }
  attribute :editable_occupancy_states, array: true, default: lambda {
    BookingFlows::Default.editable_by_default.map(&:to_s)
  }

  def self.manage_transition_to_states(organisation)
    organisation.booking_flow_class.successors['initial'].map { BookingStates[it.to_sym] }.compact_blank
  end
end
