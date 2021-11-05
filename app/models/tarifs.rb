# frozen_string_literal: true

module Tarifs
  TYPES = [Tarifs::Amount, Tarifs::Flat, Tarifs::Metered, Tarifs::OvernightStay, Tarifs::MinOccupation].freeze
end
